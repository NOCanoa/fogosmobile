import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fogos_api/features/latest_warnings/data/fires_repository.dart';
import 'package:fogos_api/features/latest_warnings/domain/fire.dart';
import 'package:fogos_api/shared/dependency_injection.dart';
import 'package:fogospt/constants/assets.dart';
import 'package:fogospt/constants/colors.dart';
import 'package:fogospt/features/fires/application/fires/fires_cubit.dart';
import 'package:fogospt/features/fires/application/fires/fires_state.dart';
import 'package:fogospt/features/fires/data/fires_flchart_data.dart';
import 'package:fogospt/features/fires/data/warning_service.dart';
import 'package:fogospt/features/fires/presentation/warning_app_bar.dart';
import 'package:fogospt/features/fires/presentation/widgets/fire_risk_state_icon_widget.dart';
import 'package:fogospt/features/fires/presentation/widgets/fire_risk_widget.dart';
import 'package:fogospt/features/fires/presentation/widgets/warning_chart_labels_item_widget.dart';
import 'package:fogospt/features/fires/presentation/widgets/warning_chart_labels_widget.dart';
import 'package:fogospt/widgets/app_fogos_title_widget.dart';
import 'package:intl/intl.dart';
import 'package:warnings/warnings.dart';

class WarningDetailPage extends StatelessWidget {
  final Fire? warning;
  const WarningDetailPage({super.key, this.warning});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FiresCubit(
        WarningService(
          getIt<FiresRepository>(),
        ),
      ),
      child: BlocBuilder<FiresCubit, FiresState>(
        builder: (context, state) {
          switch (state) {
            case FiresStateInitial():
              BlocProvider.of<FiresCubit>(context)
                  .fetchWarning(warning?.id ?? '');
              return WarningLoadingView();
            case FiresStateLoading():
              return WarningLoadingView();
            case FiresStateLoaded():
              return WarningLoadedView();
            case FiresStateFailed():
              return WarningFailedView();
          }
        },
      ),
    );
  }
}

class WarningFailedView extends StatelessWidget {
  const WarningFailedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WarningAppBar(),
      body: Center(
        child: Text('Failed to load warning'),
      ),
    );
  }
}

class WarningLoadingView extends StatelessWidget {
  const WarningLoadingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WarningAppBar(),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class WarningLoadedView extends StatelessWidget {
  const WarningLoadedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiresCubit, FiresState>(
      builder: (context, state) {
        if (state is FiresStateLoaded) {
          return Scaffold(
            appBar: WarningAppBar(warning: state.fire),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFogosTitleWidget(title: "LOCAL"),
                    Text(
                      state.fire.location,
                      style: context.textTheme.headlineSmall,
                    ),
                    SizedBox(height: 20),

                    /// Resources
                    AppFogosTitleWidget(title: "meios"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconAndValueWidget(
                          icon: FogosAppAssets.getAsset(ResourcesType.man),
                          value: state.latestResource.man,
                        ),
                        IconAndValueWidget(
                          icon: FogosAppAssets.getAsset(ResourcesType.terrain),
                          value: state.latestResource.terrain,
                        ),
                        IconAndValueWidget(
                          icon: FogosAppAssets.getAsset(ResourcesType.aerial),
                          value: state.latestResource.aerial,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    /// Resources Graph
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final data = WarningFlChartData(
                          resources: state.resources,
                        );

                        return SizedBox.fromSize(
                          size: Size(constraints.maxWidth, 300),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: data.axisY(),
                                titlesData: titlesData(),
                                lineTouchData: lineTouchData(),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: data.manToFlSpots(),
                                    color: resourceManColor,
                                    barWidth: 4,
                                  ),
                                  LineChartBarData(
                                    spots: data.terrainToFlSpots(),
                                    color: resourceTerrainColor,
                                    barWidth: 4,
                                  ),
                                  LineChartBarData(
                                    spots: data.aerialToFlSpots(),
                                    color: resourceAerialColor,
                                    barWidth: 4,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),

                    /// Labels
                    WarningChartLabels.spaceEvenly(
                      labels: [
                        WarningChartLabelsItemWidget(
                          color: resourceManColor,
                          label: 'Operacionais',
                        ),
                        WarningChartLabelsItemWidget(
                          color: resourceTerrainColor,
                          label: 'Terrestres',
                        ),
                        WarningChartLabelsItemWidget(
                          color: resourceAerialColor,
                          label: 'Aéreos',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    /// Inicio
                    AppFogosTitleWidget(title: "início"),
                    Text(
                      "${state.fire.date} ${state.fire.hour}",
                      style: context.textTheme.headlineSmall,
                    ),
                    SizedBox(height: 20),

                    /// Natureza
                    AppFogosTitleWidget(title: "natureza"),
                    Text(
                      state.fire.natureza,
                      style: context.textTheme.headlineSmall,
                    ),
                    SizedBox(height: 20),

                    /// FONTE DE ALERTA
                    // AppFogosTitleWidget(title: "fonte de alerta"),
                    // SizedBox(height: 20),

                    /// Risco de Incêndio
                    AppFogosTitleWidget(title: "risco de incêndio"),

                    FireRiskWidget(rcm: state.latestRCM),
                    SizedBox(height: 20),

                    /// ESTADO
                    AppFogosTitleWidget(title: "estado"),
                    Column(
                      children: [
                        ...state.historyStatuses.map<Widget>(
                          (status) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IntrinsicHeight(
                                  child: Stack(
                                    alignment: AlignmentDirectional.topCenter,
                                    children: [
                                      RiskFireStateIconWidget(
                                        status: status,
                                        icon: icoFire,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 1.5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      status.label,
                                      style: context.textTheme.bodyLarge
                                          ?.copyWith(color: appFogosOrange),
                                    ),
                                    Text(
                                      status.status,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ],
                    ),

                    /// METEO?
                    Visibility(
                      // visible: kDebugMode,
                      visible: false,
                      child: AppFogosTitleWidget(title: "meteo"),
                    ),

                    /// PARTILHAR
                    Visibility(
                      // visible: kDebugMode,
                      visible: false,
                      child: AppFogosTitleWidget(title: "partilhar"),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: WarningAppBar(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  LineTouchData lineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.lightGreen,
      ),
    );
  }

  FlTitlesData titlesData() {
    return FlTitlesData(
      topTitles: AxisTitles(
        axisNameWidget: Text('Meios'),
        axisNameSize: 20,
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: Text('Meios'),
        axisNameSize: 0,
        sideTitles: SideTitles(
          showTitles: true,
          interval: 10,
          getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: daysOfWeekBottomTitle(),
      ),
    );
  }

  SideTitles daysOfWeekBottomTitle() {
    // final data = getIt<WarningFlChartData>();
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        ;
        return SideTitleWidget(
          axisSide: meta.axisSide,
          angle: 125,
          child: Text(DateFormat("dd/MM hh:mm").format(dateTime)),
        );
      },
    );
  }
}
