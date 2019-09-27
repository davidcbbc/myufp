// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Horizontal bar chart with custom style for each datum in the bar label.
// EXCLUDE_FROM_GALLERY_DOCS_START
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:myufp/models/disciplina.dart';

class HorizontalBarLabelCustomChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalBarLabelCustomChart(this.seriesList, {this.animate});

    factory HorizontalBarLabelCustomChart.withDiscipline(List<Disciplina> lista) {
    return new HorizontalBarLabelCustomChart(_createDisciplineData(lista));
  }

static List<charts.Series<Disciplina, String>> _createDisciplineData(List<Disciplina> lista) {
    //final data = [];
    List<Disciplina> data = new List();
    lista.forEach((dip) {
      int how = dip.howMany();
      if(how == 2) {
        data.add(new Disciplina.chart("${dip.nome} PL", int.parse(dip.assiduidade_pl)));
        data.add(new Disciplina.chart("${dip.nome} TP", int.parse(dip.assiduidade_tp)));
      }
      if(how == 1) data.add(new Disciplina.chart("${dip.nome} PL", int.parse(dip.assiduidade_pl)));
      if(how == 0) data.add(new Disciplina.chart("${dip.nome} TP", int.parse(dip.assiduidade_tp)));
    });

    return [
      new charts.Series<Disciplina, String>(
        id: 'Disciplina',
        domainFn: (Disciplina dp, _) => dp.nome,
        measureFn: (Disciplina dp, _) => dp.nota_chart,
        data: data,
        colorFn: (Disciplina dp, __) {
          int nota = dp.nota_chart;
          if(nota >= 60) return charts.MaterialPalette.green.shadeDefault;
          if(nota >= 50 && nota < 60) return charts.Color.fromHex(code: "#FFE401");
          if(nota < 50 && nota >=20) return charts.Color.fromHex(code: "#FF9B00");
          if(nota < 20) return charts.Color.fromHex(code: "#D40000");
          return null;
          
        },
        labelAccessorFn: (Disciplina dp, _) =>
            '${dp.nome}: ${dp.nota_chart}%',
      ),
    ];
  }


  // The [BarLabelDecorator] has settings to set the text style for all labels
  // for inside the bar and outside the bar. To be able to control each datum's
  // style, set the style accessor functions on the series.
  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      // Hide domain axis.
      domainAxis:
          new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }
}