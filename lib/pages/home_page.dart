import 'package:flutter/cupertino.dart';
import 'package:cadastro_cerveja/supabase_manager.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    SupabaseManager supabaseManager = SupabaseManager();

    return FutureBuilder(
        future:
        supabaseManager.buscarComboAbastecimento(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            return MyWidget(snapshot.data);
          }
        }
    );

  }
}

class MyWidget extends StatelessWidget {
  MyWidget(this.data);

  final data;

  build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
         return ListTile(
           leading: Icon(
             Icons.local_gas_station,
              color: Colors.deepPurple,
             size: 30,
           ),
           title: Text(
             data[index].modelo,
              style: TextStyle(
                fontSize: 20,
              ),
           ),
           subtitle: Text(
             formatDate(data[index].data) + ' - ' + data[index].posto.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
              ),
           ),
           trailing:
             Column(
               children:[
                 Text(
                   "R\$ "+data[index].preco.toString(),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                 ),
                  Text(
                    data[index].litros.toString() + " L",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
               ]
             )
         );
        },
        padding: EdgeInsets.all(10),
        separatorBuilder: (_, __) => Divider(),
        itemCount: data.length,
    );
  }

  formatDate(data) {
    String dataFormatada = data.toString();
    dataFormatada = dataFormatada.substring(8,10) + '/' + dataFormatada.substring(5,7) + '/' + dataFormatada.substring(0,4);
    return dataFormatada;
  }

}