
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'cadastro_page.dart';
import 'relatorio_page.dart';

class AppPage extends StatefulWidget{
  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {

  int _opcaoSelecionada=0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _opcaoSelecionada,
          onTap: (opcao) {
            setState(() {
              _opcaoSelecionada = opcao;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline_rounded),
                label: 'Cadastro'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Relatórios'
            )
          ],
        ),
        appBar: AppBar(
          title: Text('Cadastro Abastecimento'),
        ),
        body: IndexedStack(
          index: _opcaoSelecionada,
          children: <Widget>[
            HomePage(),
            Cadastro(),
            Relatorios(),
          ],
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }

}