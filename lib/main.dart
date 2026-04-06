import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const IOS26CalculatorApp());
}

class IOS26CalculatorApp extends StatefulWidget {
  const IOS26CalculatorApp({super.key});

  @override
  State<IOS26CalculatorApp> createState() => _IOS26CalculatorAppState();
}

class _IOS26CalculatorAppState extends State<IOS26CalculatorApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // تم تفتيح الخلفية السوداء قليلاً لتكون مريحة أكثر
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'SF Pro Display',
      ),
      themeMode: _themeMode,
      home: CalculatorScreen(
        currentMode: _themeMode,
        onThemeChanged: _setTheme,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onThemeChanged;

  const CalculatorScreen({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _currentInput = '0';
  String _previousInput = '';
  String? _operator;
  bool _shouldResetScreen = false;
  String _history = '';

  final Color _activeGreen = const Color(0xFF4ADE80);

  void _onPressed(String text) {
    setState(() {
      if (RegExp(r'[0-9]').hasMatch(text)) {
        _appendNumber(text);
      } else if (text == '.') {
        _appendNumber('.');
      } else if (text == 'AC') {
        _clear();
      } else if (text == '±') {
        _toggleSign();
      } else if (text == '%') {
        _percentage();
      } else if (text == '=') {
        _calculate();
      } else {
        _setOperator(text);
      }
    });
  }

  void _appendNumber(String number) {
    if (_currentInput == '0' || _shouldResetScreen) {
      _currentInput = (number == '.') ? '0.' : number;
      _shouldResetScreen = false;
    } else {
      if (number == '.' && _currentInput.contains('.')) return;
      if (_currentInput.length < 9) {
        _currentInput += number;
      }
    }
  }

  void _clear() {
    _currentInput = '0';
    _previousInput = '';
    _operator = null;
    _history = '';
  }

  void _toggleSign() {
    double val = double.tryParse(_currentInput) ?? 0;
    _currentInput = (val * -1).toString();
    _cleanTrailingZeros();
  }

  void _percentage() {
    double val = double.tryParse(_currentInput) ?? 0;
    _currentInput = (val / 100).toString();
    _cleanTrailingZeros();
  }

  void _setOperator(String op) {
    if (_operator != null && !_shouldResetScreen) _calculate();
    _previousInput = _currentInput;
    _operator = op;
    _history = '$_previousInput $_operator';
    _shouldResetScreen = true;
  }

  void _calculate() {
    if (_operator == null || _shouldResetScreen) return;
    double prev = double.tryParse(_previousInput) ?? 0;
    double current = double.tryParse(_currentInput) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = prev + current;
        break;
      case '-':
        result = prev - current;
        break;
      case '×':
        result = prev * current;
        break;
      case '÷':
        result = (current == 0) ? 0 : prev / current;
        break;
    }

    _history = '$_previousInput $_operator $_currentInput =';
    _currentInput = result.toString();
    _cleanTrailingZeros();
    _operator = null;
    _shouldResetScreen = true;
  }

  void _cleanTrailingZeros() {
    if (_currentInput.contains('.')) {
      _currentInput = _currentInput.replaceAll(RegExp(r'\.0$'), '');
    }
    if (_currentInput.length > 10) {
      _currentInput = double.parse(_currentInput).toStringAsPrecision(7);
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C1C1E)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "الإعدادات",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    "المظهر الداكن",
                    Icons.dark_mode,
                    ThemeMode.dark,
                  ),
                  const Divider(height: 1, indent: 50),
                  _buildThemeOption(
                    "المظهر الفاتح",
                    Icons.light_mode,
                    ThemeMode.light,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, ThemeMode mode) {
    bool isSelected = widget.currentMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? _activeGreen : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? _activeGreen : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: _activeGreen) : null,
      onTap: () {
        widget.onThemeChanged(mode);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double padding = 16.0;
            final double spacing = 10.0;
            double buttonSize =
                (constraints.maxWidth - (padding * 2) - (spacing * 3)) / 4;

            if (buttonSize * 7 > constraints.maxHeight) {
              buttonSize = constraints.maxHeight / 7.5;
            }

            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: padding + 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                _history,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: primaryTextColor.withOpacity(0.4),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _currentInput,
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.w200,
                                  color: primaryTextColor,
                                  letterSpacing: -2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(padding, 10, padding, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRow(
                            ['AC', '±', '%', '÷'],
                            buttonSize,
                            spacing,
                            isAction: true,
                            isDark: isDark,
                          ),
                          _buildRow(
                            ['7', '8', '9', '×'],
                            buttonSize,
                            spacing,
                            isDark: isDark,
                          ),
                          _buildRow(
                            ['4', '5', '6', '-'],
                            buttonSize,
                            spacing,
                            isDark: isDark,
                          ),
                          _buildRow(
                            ['1', '2', '3', '+'],
                            buttonSize,
                            spacing,
                            isDark: isDark,
                          ),
                          _buildRow(
                            ['0', '.', '='],
                            buttonSize,
                            spacing,
                            isLast: true,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 134,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: primaryTextColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: _showSettings,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryTextColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryTextColor.withOpacity(0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: primaryTextColor.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(
    List<String> labels,
    double size,
    double spacing, {
    bool isAction = false,
    bool isLast = false,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map<Widget>((label) {
          bool isOperator = ['÷', '×', '-', '+'].contains(label);
          bool isEqual = label == '=';
          bool isZero = label == '0';

          return _buildButton(
            label,
            size,
            spacing,
            isOperator: isOperator,
            isAction: isAction && !isOperator,
            isEqual: isEqual,
            isZero: isZero,
            isDark: isDark,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(
    String label,
    double size,
    double spacing, {
    bool isOperator = false,
    bool isAction = false,
    bool isEqual = false,
    bool isZero = false,
    required bool isDark,
  }) {
    final primaryTextColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => _onPressed(label),
      child: Container(
        width: isZero ? (size * 2) + spacing : size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2.2),
          color: isEqual
              ? const Color(0xFFFF9F0A)
              : isOperator
              ? const Color(0xFF0A84FF).withOpacity(isDark ? 0.2 : 0.1)
              : isAction
              ? primaryTextColor.withOpacity(isDark ? 0.12 : 0.05)
              : primaryTextColor.withOpacity(isDark ? 0.08 : 0.03),
          border: isOperator
              ? Border.all(
                  color: const Color(0xFF0A84FF).withOpacity(0.4),
                  width: 0.5,
                )
              : Border.all(
                  color: primaryTextColor.withOpacity(0.05),
                  width: 0.5,
                ),
          boxShadow: isEqual
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9F0A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2.2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isAction ? size * 0.3 : size * 0.35,
                  fontWeight: (isOperator || isEqual)
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isOperator
                      ? const Color(0xFF0A84FF)
                      : (isEqual ? Colors.white : primaryTextColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
