import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinScreen extends StatefulWidget {
  final bool isSettingPin;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PinScreen({
    super.key,
    required this.isSettingPin,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _storage = const FlutterSecureStorage();
  String _input = '';
  String _firstInput = '';
  bool _isConfirming = false;
  bool _hasError = false;

  void _onNumberPressed(String number) async {
    if (_input.length < 4) {
      setState(() {
        _input += number;
        _hasError = false;
      });

      if (_input.length == 4) {
        await Future.delayed(const Duration(milliseconds: 200));
        _processPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _hasError = false;
      });
    }
  }

  Future<void> _processPin() async {
    if (widget.isSettingPin) {
      if (!_isConfirming) {
        setState(() {
          _firstInput = _input;
          _input = '';
          _isConfirming = true;
        });
      } else {
        if (_input == _firstInput) {
          await _storage.write(key: 'app_pin', value: _input);
          widget.onSuccess();
        } else {
          setState(() {
            _input = '';
            _firstInput = '';
            _isConfirming = false;
            _hasError = true;
          });
        }
      }
    } else {
      final storedPin = await _storage.read(key: 'app_pin');
      if (_input == storedPin) {
        widget.onSuccess();
      } else {
        setState(() {
          _input = '';
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Enter PIN';
    if (widget.isSettingPin) {
      title = _isConfirming ? 'Confirm PIN' : 'Create 4-digit PIN';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_hasError)
              Text(
                'PIN mismatch / incorrect PIN',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const SizedBox(height: 20),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _input.length
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            ),
            const SizedBox(height: 64),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 72),
              _buildNumberButton('0'),
              SizedBox(
                width: 72,
                child: IconButton(
                  iconSize: 32,
                  onPressed: _onBackspacePressed,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _onNumberPressed(number),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
