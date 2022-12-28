import 'package:cadastro_cerveja/classes/Abastecimento_relatorio.dart';
import 'package:supabase/supabase.dart';
import 'package:cadastro_cerveja/classes/usuarios.dart';
import 'classes/abastecimento.dart';
import 'classes/carro.dart';
import 'classes/abastecimento_resumo.dart';
import 'classes/medias_relatorio.dart';

const supabaseUrl = 'https://rxnolfsrlpbzucwuxqdm.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4bm9sZnNybHBienVjd3V4cWRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzAzNDI3OTEsImV4cCI6MTk4NTkxODc5MX0.OvO-VMN_wKWVJZ8JKEwSUS0vR6zm5akT6XmTABuYbow';

class SupabaseManager{

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  Future<bool> logar(String login, String password) async{
    try {
      final result = await client
          .from('usuario')
          .select('*');
      return verifyLogin(result, login, password);
    }catch(error){
      return false;
    }
  }

  bool verifyLogin(List result, String login, String password) {
    bool autenticado = false;
    result.forEach((user) {
      if(login==user['login'] && password==user['password']) {
        autenticado = true;
      }
    });
    return autenticado;
  }

  Future<List<Carro>> buscarComboCarrosAtivos() async{
    final result = await client
        .from('carro')
        .select('*')
        .not('flag_ativo', 'is', false);


    List<Carro> carros = [];

    result.forEach((carroMap) {
      Carro car = Carro(carroMap['id_carro'], carroMap['modelo'], carroMap['marca'], carroMap['ano']);
      carros.add(car);
    });
    return carros;

  }

  void cadastrarAbastecimento(double preco, double litros, String data, int km, String posto, int? carro) async {
    final result = await client
        .from('abastecimento')
        .select('*')
    .eq('id_carro', carro)
    .order('data', ascending: false)
    .limit(1);

    int kmAnterior = 0;
    double media = 0;

    if(result!=null && result.length>0){
      kmAnterior = result[0]['km'];
      media = (km - kmAnterior) / litros;
    }

    await client
        .from('abastecimento')
        .insert([
      {
        'preco': preco,
        'litros': litros,
        'data': data,
        'km': km,
        'posto': posto,
        'id_carro': carro,
        'preco_por_litro': preco/litros,
        'km_anterior': kmAnterior,
        'media_consumo': media
      }
    ]);
  }

  buscarComboAbastecimento() async {
    // final result = await client
    //     .rpc('get_ultimos_abastecimentos');

    final res = await client
        .from('abastecimento')
        .select('''
        carro:id_carro (modelo),
        data,
        preco,
        litros,
        preco_por_litro,
        posto
  ''')
    .order('data', ascending: false)
    .limit(10);

    List<AbastecimentoResumo> abastecimentos = [];

    res.forEach((abastecimentoMap) {
      var teste = abastecimentoMap['carro'];
        AbastecimentoResumo abastecimento = AbastecimentoResumo(
            teste['modelo'],
            abastecimentoMap['data'],
            abastecimentoMap['preco'].toDouble(),
            abastecimentoMap['litros'].toDouble(),
            abastecimentoMap['preco_por_litro'].toDouble(),
            abastecimentoMap['posto'] ?? ''
        );
        abastecimentos.add(abastecimento);
      });
    return abastecimentos;
  }

  buscarRelatorio(String dataIni, String dataFim, int? selectedCar) async{
    final res = await client
        .from('abastecimento')
        .select('''
        data,
        km,
        preco,
        litros,
        preco_por_litro,
        km_anterior,
        media_consumo
  ''')
        .eq("id_carro", selectedCar)
        .order('data', ascending: true);

    List<AbastecimentoRelatorio> abastecimentosGeral = [];
    List<AbastecimentoRelatorio> abastecimentosPeriodo = [];

    res.forEach((abastecimentoMap) {
      AbastecimentoRelatorio abastecimento = AbastecimentoRelatorio(
          abastecimentoMap['data'],
          abastecimentoMap['km'].toInt(),
          abastecimentoMap['preco'].toDouble(),
          abastecimentoMap['litros'].toDouble(),
          abastecimentoMap['preco_por_litro'].toDouble(),
          abastecimentoMap['km_anterior'].toInt(),
          abastecimentoMap['media_consumo'].toDouble()
      );
      abastecimentosGeral.add(abastecimento);

      if(abastecimento.data.compareTo(dataIni)>=0 && abastecimento.data.compareTo(dataFim)<=0){
        abastecimentosPeriodo.add(abastecimento);
      }
    });

    return realizarCalculoMedias(abastecimentosGeral, abastecimentosPeriodo);

  }

  realizarCalculoMedias(List<AbastecimentoRelatorio> abastecimentosGeral, List<AbastecimentoRelatorio> abastecimentosPeriodo) {


    int _kmGeral = 0;
    int _kmPeriodo = 0;
    double _litrosGeral = 0;
    double _litrosPeriodo = 0;
    double _mediaKmGeral = 0;
    double _mediaKmPeriodo = 0;
    double _precoGeral = 0;
    double _precoPeriodo = 0;
    double _mediaPrecoGeral = 0;
    double _mediaPrecoPeriodo = 0;
    double _custoMedioKmRodadoGeral = 0;
    double _custoMedioKmRodadoPeriodo = 0;

    if(abastecimentosGeral.length>1) {
      abastecimentosGeral.forEach((abastecimento) {
        _litrosGeral += abastecimento.litros;
        _precoGeral += abastecimento.preco;
        _mediaKmGeral += abastecimento.mediaConsumo;
      });
      _kmGeral = abastecimentosGeral.last.km - abastecimentosGeral.first.km;
      _mediaKmGeral = _mediaKmGeral / abastecimentosGeral.length;
      _mediaPrecoGeral = _precoGeral / _litrosGeral;
      _custoMedioKmRodadoGeral = _precoGeral / _kmGeral;
    }else if(abastecimentosGeral.length==1){
      _kmGeral = abastecimentosGeral.first.km;
      _litrosGeral = abastecimentosGeral[0].litros;
      _precoGeral = abastecimentosGeral[0].preco;
      _mediaKmGeral = abastecimentosGeral[0].mediaConsumo;
      _mediaPrecoGeral = abastecimentosGeral[0].precoPorLitro;
      _custoMedioKmRodadoGeral = abastecimentosGeral[0].preco / (abastecimentosGeral[0].km-abastecimentosGeral[0].kmAnterior);
    }

    if(abastecimentosPeriodo.length>1) {
      abastecimentosPeriodo.forEach((abastecimento) {
        _litrosPeriodo += abastecimento.litros;
        _precoPeriodo += abastecimento.preco;
        _mediaKmPeriodo += abastecimento.mediaConsumo;
      });
      _kmPeriodo = abastecimentosPeriodo.last.km - abastecimentosPeriodo.first.km;
      _mediaKmPeriodo = _mediaKmPeriodo / abastecimentosPeriodo.length;
      _mediaPrecoPeriodo = _precoPeriodo / _litrosPeriodo;
      _custoMedioKmRodadoPeriodo = _precoPeriodo / _kmPeriodo;
    }else if(abastecimentosPeriodo.length==1){
      _kmPeriodo = abastecimentosPeriodo.first.km;
      _litrosPeriodo = abastecimentosPeriodo[0].litros;
      _precoPeriodo = abastecimentosPeriodo[0].preco;
      _mediaKmPeriodo = abastecimentosPeriodo[0].mediaConsumo;
      _mediaPrecoPeriodo = abastecimentosPeriodo[0].precoPorLitro;
      _custoMedioKmRodadoPeriodo = abastecimentosPeriodo[0].preco / (abastecimentosPeriodo[0].km-abastecimentosPeriodo[0].kmAnterior);
    }

    MediasRelatorio medias = MediasRelatorio(
        _kmGeral,
        _kmPeriodo,
        _litrosGeral,
        _litrosPeriodo,
        _mediaKmGeral,
        _mediaKmPeriodo,
        _precoGeral,
        _precoPeriodo,
        _mediaPrecoGeral,
        _mediaPrecoPeriodo,
        _custoMedioKmRodadoGeral,
        _custoMedioKmRodadoPeriodo
    );

    return medias;

  }




}
