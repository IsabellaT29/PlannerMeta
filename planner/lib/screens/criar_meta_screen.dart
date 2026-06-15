import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/meta.dart';
import '../models/micrometa.dart';
import '../data/repositories/meta_repository.dart';
import '../data/repositories/micrometa_repository.dart';

class CriarMetaScreen extends StatefulWidget {
  final int usuarioId;

  const CriarMetaScreen({super.key, required this.usuarioId});

  @override
  State<CriarMetaScreen> createState() => _CriarMetaScreenState();
}

class _MicrometaTemp {
  String descricao = '';
  int frequenciaId = 1; // 1: Diária, 2: Semanal, 3: Mensal
  List<int> diasSemana = []; // 0=Dom, 1=Seg...
  List<int> diasMes = []; // 1 a 31 
}

class _CriarMetaScreenState extends State<CriarMetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoMetaController = TextEditingController();
  final TextEditingController _prazoController = TextEditingController();

  final List<_MicrometaTemp> _micrometas = [];
  final MetaRepository _metaRepo = MetaRepository();
  final MicrometaRepository _micrometaRepo = MicrometaRepository();

  @override
  void initState() {
    super.initState();
    _adicionarMicrometa(); // Inicia com pelo menos 1
  }

  @override
  void dispose() {
    _descricaoMetaController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  void _adicionarMicrometa() {
    setState(() => _micrometas.add(_MicrometaTemp()));
  }

  void _removerMicrometa(int index) {
    if (_micrometas.length > 1) {
      setState(() => _micrometas.removeAt(index));
    } else {
      _mostrarAviso('A meta deve ter pelo menos uma micrometa!');
    }
  }

  void _mostrarAviso(String mensagem, {bool sucesso = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: sucesso ? Colors.green : AppColors.escuro,
        ),
      );
    }
  }

  Future<void> _selecionarPrazo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'), // Força o calendário para Português
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.escuro,
              onPrimary: AppColors.branco,
              onSurface: AppColors.escuro,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _prazoController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _salvarNoBanco() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Validações das frequências
    for (var i = 0; i < _micrometas.length; i++) {
      var mm = _micrometas[i];
      if (mm.frequenciaId == 2 && mm.diasSemana.isEmpty) {
        _mostrarAviso('Selecione pelo menos um dia da semana na Micrometa ${i + 1}');
        return;
      }
      if (mm.frequenciaId == 3 && mm.diasMes.isEmpty) {
        _mostrarAviso('Selecione pelo menos um dia do mês na Micrometa ${i + 1}');
        return;
      }
    }

    try {
      // 1. Salvar a Meta
      final novaMeta = Meta(
        usuarioId: widget.usuarioId,
        descricao: _descricaoMetaController.text,
        prazo: _prazoController.text,
      );
      
      final int metaIdSalva = await _metaRepo.inserir(novaMeta);

      // 2. Salvar as Micrometas
      for (var temp in _micrometas) {
        if (temp.frequenciaId == 1) { 
          // Diária (diaEspecifico = null)
          await _micrometaRepo.inserir(Micrometa(metaId: metaIdSalva, frequenciaId: 1, descricao: temp.descricao));
        } else if (temp.frequenciaId == 2) { 
          // Semanal: Cria uma linha para cada dia marcado
          for (var dia in temp.diasSemana) {
            await _micrometaRepo.inserir(Micrometa(metaId: metaIdSalva, frequenciaId: 2, descricao: temp.descricao, diaEspecifico: dia));
          }
        } else if (temp.frequenciaId == 3) { 
          // Mensal: Cria uma linha para cada dia marcado
          for (var dia in temp.diasMes) {
            await _micrometaRepo.inserir(Micrometa(metaId: metaIdSalva, frequenciaId: 3, descricao: temp.descricao, diaEspecifico: dia));
          }
        }
      }

      // 3. Feedback e fechar a tela
      _mostrarAviso('Meta cadastrada com sucesso!', sucesso: true); // verde por ser sucesso
      
      if (mounted) {
        Navigator.pop(context); // Retorna para a MetasScreen 
      }

    } catch (e) {
      _mostrarAviso('Erro ao salvar meta: $e');
    }
  }

  // Método auxiliar 
  InputDecoration _construirDecoracao(String label, {IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.escuro),
      filled: true,
      fillColor: AppColors.branco,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.escuro) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.escuro),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.medio),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.escuro, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.claro,
      appBar: AppBar(
        backgroundColor: AppColors.medio,
        title: const Text('Criar Nova Meta', style: TextStyle(color: AppColors.escuro)),
        iconTheme: const IconThemeData(color: AppColors.escuro),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text('Dados da Meta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.escuro)),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descricaoMetaController,
              style: const TextStyle(color: AppColors.escuro),
              decoration: _construirDecoracao('Descrição da Meta'),
              validator: (val) => val == null || val.isEmpty ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _prazoController,
              readOnly: true,
              style: const TextStyle(color: AppColors.escuro),
              onTap: () => _selecionarPrazo(context),
              decoration: _construirDecoracao('Prazo', suffixIcon: Icons.calendar_today),
              validator: (val) => val == null || val.isEmpty ? 'Selecione o prazo' : null,
            ),
            
            const Divider(height: 48, thickness: 2, color: AppColors.medio),
            
            const Text('Micrometas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.escuro)),
            const SizedBox(height: 16),
            
            ..._micrometas.asMap().entries.map((entry) {
              int index = entry.key;
              _MicrometaTemp micrometa = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.branco,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.medio),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Micrometa ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.escuro)),
                        if (_micrometas.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerMicrometa(index),
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(color: AppColors.escuro),
                      decoration: _construirDecoracao('O que você vai fazer?'),
                      initialValue: micrometa.descricao,
                      onChanged: (val) => micrometa.descricao = val,
                      validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: _construirDecoracao('Frequência'),
                      style: const TextStyle(color: AppColors.escuro),
                      dropdownColor: AppColors.branco,
                      value: micrometa.frequenciaId,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Diária')),
                        DropdownMenuItem(value: 2, child: Text('Semanal')),
                        DropdownMenuItem(value: 3, child: Text('Mensal')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          micrometa.frequenciaId = val!;
                          micrometa.diasSemana.clear();
                          micrometa.diasMes.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    if (micrometa.frequenciaId == 2)
                      _buildSeletorSemanal(micrometa)
                    else if (micrometa.frequenciaId == 3)
                      _buildSeletorMensal(micrometa),
                  ],
                ),
              );
            }),

            TextButton.icon(
              onPressed: _adicionarMicrometa,
              icon: const Icon(Icons.add_circle, color: AppColors.escuro),
              label: const Text('ADICIONAR OUTRA MICROMETA', style: TextStyle(color: AppColors.escuro, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _salvarNoBanco,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) return const Color(0xFF6B2036); 
                    return AppColors.escuro; 
                  },
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              child: const Text('SALVAR META', style: TextStyle(color: AppColors.branco, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeletorSemanal(_MicrometaTemp micrometa) {
    const dias = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']; // 0: Dom, 1: Seg...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecione os dias da semana:', style: TextStyle(color: AppColors.escuro, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(dias.length, (i) {
            bool isSelected = micrometa.diasSemana.contains(i);
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected ? micrometa.diasSemana.remove(i) : micrometa.diasSemana.add(i);
                });
              },
              child: _bolinhaSelecao(dias[i], isSelected),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSeletorMensal(_MicrometaTemp micrometa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecione os dias do mês:', style: TextStyle(color: AppColors.escuro, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, // Espaço horizontal entre as bolinhas
          runSpacing: 8, // Espaço vertical entre as linhas
          children: List.generate(31, (index) {
            int dia = index + 1;
            bool isSelected = micrometa.diasMes.contains(dia);
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected ? micrometa.diasMes.remove(dia) : micrometa.diasMes.add(dia);
                });
              },
              child: _bolinhaSelecao(dia.toString(), isSelected),
            );
          }),
        ),
      ],
    );
  }

  // Componente visual padronizado para as bolinhas rosadas
  Widget _bolinhaSelecao(String texto, bool isSelected) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFB57B8C) : const Color(0xFFEBE0E2),
      ),
      alignment: Alignment.center,
      child: Text(
        texto,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF5A3A42),
          fontWeight: FontWeight.bold,
          fontSize: texto.length > 1 ? 12 : 14, // Ajusta o tamanho da fonte se o número tiver 2 dígitos
        ),
      ),
    );
  }
}