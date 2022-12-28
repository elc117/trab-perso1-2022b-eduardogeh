import 'package:flutter/material.dart';

class AbastecimentoResumo{
  String modelo;
  String data;
  double preco;
  double litros;
  double precoPorLitro;
  String posto;

  AbastecimentoResumo(this.modelo, this.data, this.preco, this.litros, this.precoPorLitro, this.posto);
}