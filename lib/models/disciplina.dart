import 'dart:core';

class Disciplina {
  String nome = '';
  String definicao = "";

  String horaDoExame;
  String dataDoExame;
  List<String> salasDoExame;
  List<String> profsDoExame;

  String assiduidade_tp = ''; 
  String assiduidade_pl = '';

  String nota_final = '';
  String nota_tp = '';
  String nota_pl = '';
  String ano = '';

  int nota_chart;                   //inteiro para ser usado no tamanho da barras da assiduidade
 

  Disciplina();
  Disciplina.assiduidade_validada(this.nome,{this.assiduidade_pl,this.assiduidade_tp});
  Disciplina.chart(this.nome,this.nota_chart);
  Disciplina.nota_detailed(this.nome,this.definicao,this.nota_final,{this.ano,this.nota_tp,this.assiduidade_pl});
  Disciplina.nota_final(this.nome, this.nota_final);
  Disciplina.exame(this.nome,this.dataDoExame,this.horaDoExame,this.salasDoExame,this.profsDoExame);




  int howMany() {
    //este metodo retorna o numero de componentes que a cadeira tem
    //valor de retorno 0 -> compomente tp
    //valor de retorno 1 -> componente pl
    //valor de retorno 2 -> ambas
    if( assiduidade_pl != null && assiduidade_tp != null) return 2;
    if( assiduidade_pl != null && assiduidade_tp == null ) return 1;
    if( assiduidade_pl == null && assiduidade_tp != null ) return 0;
    return null;
  }


}