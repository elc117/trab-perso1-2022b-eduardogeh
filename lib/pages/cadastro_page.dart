

import 'package:cadastro_cerveja/classes/carro.dart';
import 'package:cadastro_cerveja/pages/home_page.dart';
import 'package:cadastro_cerveja/supabase_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Cadastro extends StatefulWidget{

  @override
  State<Cadastro> createState() => _CadastroState();
}


SupabaseManager supabaseManager = SupabaseManager();

NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
DateTime iniDate = DateTime(2000, 1, 1);
DateTime endDate = DateTime(2100, 1, 1);

List<Carro>? _carrosList;
int? _selectedCar;

final _formCadastro = GlobalKey<FormState>();

final _preco = TextEditingController();

final _litros = TextEditingController();

final _data = TextEditingController();

final _km = TextEditingController();

final _posto = TextEditingController();

validator(value){
  if(!(value!.isEmpty) && double.parse(value) < 0)
    return 'Informe um valor válido';
  else if(value==null)
    return 'Campo obrigatório';
}

class _CadastroState extends State<Cadastro> {

  _CadastroState(){

  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: buscarCarro(),
        builder: (context, snapshot) {
          if (_carrosList == null) {
            return Container();
          } else {
            return MyWidgetCadastro(snapshot.data);
          }
        }
    );

  }

  buscarCarro() {
    Future<List<Carro>> carros = supabaseManager.buscarComboCarrosAtivos();
    carros.then((value) => _carrosList = value);
  }

}

class MyWidgetCadastro extends StatefulWidget{
  MyWidgetCadastro(this.data);

  final data;

  @override
  State<MyWidgetCadastro> createState() => _MyWidgetCadastroState();
}

class _MyWidgetCadastroState extends State<MyWidgetCadastro> {

  _MyWidgetCadastroState(){
    _selectedCar = _carrosList![0].id_carro;
  }

  cadastrar() async{
    try {
      if (_formCadastro.currentState!.validate()) {
        var data = DateFormat('yyyy-MM-dd').format(
            DateFormat('dd/MM/yyyy').parse(_data.text));
        supabaseManager.cadastrarAbastecimento(
            double.parse(_preco.text), double.parse(_litros.text), data,
            int.parse(_km.text), _posto.text, _selectedCar);
        _preco.clear();
        _litros.clear();
        _data.clear();
        _km.clear();
        _posto.clear();

        FocusScope.of(context).requestFocus(FocusNode());

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Sucesso!',
                message:
                'O Abastecimento foi cadastrado com sucesso',
                contentType: ContentType.success,
              ),
            )
        );
      }
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Erro!',
              message:
              'Algo inesperado aconteceu ao cadastrar o abastecimento',
              contentType: ContentType.failure,
            ),
          )
      );
    }
  }
  //build
  build(BuildContext context) {
    return Scaffold(
      body:Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formCadastro,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField  (
                  value: _selectedCar,
                  items: _carrosList!.map(
                          (car) => DropdownMenuItem(child: Text(
                        car.modelo + ' - ' + car.ano.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                          value: car.id_carro)
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCar = value as int;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.deepPurple,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Carro',
                    prefixIcon: Icon(Icons.directions_car_filled_outlined),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  onTap: () async{
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: iniDate,
                        lastDate: endDate);
                    if(pickedDate!=null){
                      setState(() {
                        _data.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                      });
                    }
                  },
                  keyboardType: TextInputType.none,
                  controller: _data,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Data Abastecimento',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _km,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Km atual',
                      prefixIcon: Icon(Icons.speed_outlined),
                      suffix: Text(
                        'KMs',
                        style: TextStyle(fontSize: 14),
                      )
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value){
                    return validator(value);
                  },
                ),
              ),
              Expanded(
                child:
                TextFormField(
                  controller: _preco,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Valor Total',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                      suffix: Text(
                        'reais',
                        style: TextStyle(fontSize: 14),
                      )
                  ),
                  keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                  validator: (value){
                    return validator(value);
                  },
                ),
              ),
              Row(
                children:[
                  Expanded(
                    child: TextFormField(
                      controller: _litros,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Combustível',
                          prefixIcon: Icon(Icons.local_gas_station_outlined),
                          suffix: Text(
                            'litros',
                            style: TextStyle(fontSize: 14),
                          )
                      ),
                      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                      validator: (value){
                        return validator(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child:
                    TextFormField(
                      controller: _posto,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Posto',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: cadastrar,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );


  }
}