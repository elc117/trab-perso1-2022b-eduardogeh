
import 'dart:ffi';

import 'package:cadastro_cerveja/classes/medias_relatorio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cadastro_cerveja/supabase_manager.dart';

import '../classes/carro.dart';

SupabaseManager supabaseManager = SupabaseManager();

List<Carro>? _carrosList;
int? _selectedCar;

DateTime iniDate = DateTime(2000, 1, 1);
DateTime endDate = DateTime(2100, 1, 1);
final _dataInicial = TextEditingController();
final _dataFinal = TextEditingController();
MediasRelatorio? relatorio = MediasRelatorio(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);


class Relatorios extends StatefulWidget{
  @override
  State<Relatorios> createState() => _RelatoriosState();
}

class _RelatoriosState extends State<Relatorios> {

  _RelatoriosState(){

  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future:
        buscarCarro(),
        builder: (context, snapshot) {
          if (_carrosList == null) {
            return Container();
          } else {
            return MyWidget(snapshot.data);
          }
        }
    );
  }

  buscarCarro() {
    Future<List<Carro>> carros = supabaseManager.buscarComboCarrosAtivos();
    carros.then((value) => _carrosList = value);
  }
}

class MyWidget extends StatefulWidget {
  MyWidget(this.data);

  final data;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {

  _MyWidgetState(){
    _selectedCar = _carrosList![0].id_carro;
  }


  build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: DropdownButtonFormField  (
                    value: _selectedCar,
                    items: _carrosList!.map(
                            (car) => DropdownMenuItem(child: Text(
                          car.modelo + ' - ' + car.ano.toString(),
                          style: TextStyle(fontSize: 15),
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
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: TextField(
                          onTap: () async{
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: iniDate,
                                lastDate: endDate);
                            if(pickedDate!=null){
                              setState(() {
                                _dataInicial.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                          keyboardType: TextInputType.none,
                          controller: _dataInicial,
                          style: TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Data Inicial',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: TextField(
                          onTap: () async{
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: iniDate,
                                lastDate: endDate);
                            if(pickedDate!=null){
                              setState(() {
                                _dataFinal.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                          keyboardType: TextInputType.none,
                          controller: _dataFinal,
                          style: TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Data Final',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: ()async{
                        var dataIni = DateFormat('yyyy-MM-dd').format(
                            DateFormat('dd/MM/yyyy').parse(_dataInicial.text));
                        var dataFim = DateFormat('yyyy-MM-dd').format(
                            DateFormat('dd/MM/yyyy').parse(_dataFinal.text));

                        relatorio = await supabaseManager.buscarRelatorio(dataIni, dataFim, _selectedCar);
                        setState(() {
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner_outlined),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Gerar',
                              style: TextStyle(fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: relatorio!=null,
                    child: Center(
                      child:Column(
                        children: [
                          DataTable(
                              columns: [
                                DataColumn(
                                    label: Text(
                                        '',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple
                                        )
                                    )
                                ),
                                DataColumn(
                                    label: Text(
                                        'Geral',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple
                                        )
                                    )
                                ),
                                DataColumn(
                                    label: Text(
                                        'Periodo',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple
                                        )
                                    )
                                ),

                              ],
                              rows: [
                                DataRow(
                                    cells:[
                                      DataCell(
                                          Text(
                                              "KM RODADOS"
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.kmGeral.toString()
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.kmPeriodo.toString()
                                          )
                                      )
                                    ]
                                ),
                                DataRow(
                                    cells:[
                                      DataCell(
                                          Text(
                                              "LITROS ABASTECIDOS"
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.litrosGeral.toStringAsFixed(2)
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.litrosPeriodo.toStringAsFixed(2)
                                          )
                                      )
                                    ]
                                ),
                                DataRow(
                                    cells:[
                                      DataCell(
                                          Text(
                                              "MEDIA P/KM"
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.mediaKmGeral.toStringAsFixed(2)
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.mediaKmPeriodo.toStringAsFixed(2)
                                          )
                                      )
                                    ]
                                ),
                                DataRow(
                                    cells:[
                                      DataCell(
                                          Text(
                                              "GASTO TOTAL (R\$)"
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.precoGeral.toStringAsFixed(2)
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.precoPeriodo.toStringAsFixed(2)
                                          )
                                      )
                                    ]
                                ),
                                DataRow(
                                    cells:[
                                      DataCell(
                                          Text(
                                              "PREÇO MÉDIO (R\$)"
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.mediaPrecoGeral.toStringAsFixed(2)
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.mediaPrecoPeriodo.toStringAsFixed(2)
                                          )
                                      )
                                    ]
                                ),
                                DataRow(
                                    cells:[
                                      DataCell(
                                          Text(
                                              "CUSTO MÉDIO P/KM (R\$)"
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.custoMedioKmRodadoGeral.toStringAsFixed(2)
                                          )
                                      ),
                                      DataCell(
                                          Text(
                                              relatorio!.custoMedioKmRodadoPeriodo.toStringAsFixed(2)
                                          )
                                      )
                                    ]
                                ),
                              ]
                          )
                        ],
                      ),
                    )
                ),
              ],
            )
        ),
      ),
      theme: ThemeData(
          primarySwatch: Colors.deepPurple
      ),
    );
  }
}
