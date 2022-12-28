import 'package:flutter/material.dart';

class AbastecimentoRelatorio{

  String data;
  int km;
  double preco;
  double litros;
  double precoPorLitro;
  int kmAnterior;
  double mediaConsumo;

  AbastecimentoRelatorio(this.data, this.km, this.preco, this.litros, this.precoPorLitro, this.kmAnterior, this.mediaConsumo);
}