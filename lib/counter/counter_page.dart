import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/counter_cubit.dart';
import 'package:wearable_rotary/wearable_rotary.dart' as wearable_rotary show rotaryEvents;
import 'package:wearable_rotary/wearable_rotary.dart' hide rotaryEvents;
import 'package:wear/wear.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  CounterView({
    Key? key,
    @visibleForTesting Stream<RotaryEvent>? rotaryEvents,
  }) : rotaryEvents = rotaryEvents ?? wearable_rotary.rotaryEvents;

  final Stream<RotaryEvent> rotaryEvents;

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late final StreamSubscription<RotaryEvent> rotarySubscription;

  @override
  void initState() {
    super.initState();
    rotarySubscription = widget.rotaryEvents.listen(handleRotaryEvent);
  }

  @override
  void dispose() {
    rotarySubscription.cancel();
    super.dispose();
  }

  void handleRotaryEvent(RotaryEvent event) {
    final cubit = context.read<CounterCubit>();
    final currentState = cubit.state;

    if (event.direction == RotaryDirection.clockwise) {
      if (currentState < 10) {
        cubit.increment();
      }
    } else {
      if (currentState > 0) {
        cubit.decrement();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (context, shape, child) {
          return AmbientMode(
            builder: (context, mode, child) {
              return Container(
                color: mode == WearMode.active ? Colors.transparent : Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Counter',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mode == WearMode.active ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: mode == WearMode.active
                                ? () => context.read<CounterCubit>().increment()
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              backgroundColor: mode == WearMode.active ? Colors.blue : Colors.grey,
                            ),
                            child: Icon(
                              Icons.add,
                              color: mode == WearMode.active ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const CounterText(),
                        const SizedBox(width: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: mode == WearMode.active
                                ? () => context.read<CounterCubit>().decrement()
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              backgroundColor: mode == WearMode.active ? Colors.blue : Colors.grey,
                            ),
                            child: Icon(
                              Icons.remove,
                              color: mode == WearMode.active ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: mode == WearMode.active
                          ? () => context.read<CounterCubit>().reset()
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: mode == WearMode.active ? Colors.orange : Colors.grey,
                      ),
                      child: Icon(
                        Icons.restore,
                        color: mode == WearMode.active ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = context.select((CounterCubit cubit) => cubit.state);
    return Text(
      '$count',
      style: theme.textTheme.headline5?.copyWith(color: Colors.white),
    );
  }
}
