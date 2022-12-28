import 'package:flutter/material.dart';

class Abastecimento{
  int id_carro;
  String data;
  double preco;
  double litros;
  int km;
  String posto;

  Abastecimento(this.id_carro, this.data, this.preco, this.litros, this.km, this.posto);
}