import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/micrometa.dart';
import '../data/repositories/meta_repository.dart';
import '../data/repositories/micrometa_repository.dart';
import '../viewmodels/micrometa_edit_viewmodel.dart';

class EditarMetaScreen extends StatefulWidget {
  final Map<String, dynamic> meta;

  const EditarMetaScreen({super.key, required this.meta});

  @override
  State<EditarMetaScreen> createState() => _EditarMetaScreenState();
}

class _EditarMetaScreenState extends State<EditarMetaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoMetaController;
  late TextEditingController _prazoController;

  final MetaRepository _metaRepo = MetaRepository();
  final MicrometaRepository _micrometaRepo = MicrometaRepository();

  List<GrupoMicrometaExistente> _gruposExistentes = [];
  final List<MicrometaNova> _micrometasNovas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _descricaoMetaController = TextEditingController(text: widget.meta['Descricao']);
    _prazoController = TextEditingController(text: widget.meta['Prazo']);
    _carregarMicrometas();
  }

  Future<void> _carregarMicrometas() async {
    final resultados = await _micrometaRepo.buscarAtivasPorMeta(widget.meta['Id']);
    Map<String, GrupoMicrometaExistente> mapaGrupos = {};

    for (var mm in resultados) {
      String chave = mm['Descricao']; 
      
      if (!mapaGrupos.containsKey(chave)) {
        mapaGrupos[chave] = GrupoMicrometaExistente(
          descricao: mm['Descricao'],
          frequenciaId: mm['FrequenciaId'],
          frequenciaOriginal: mm['FrequenciaId'], 
          diasOriginais: {},
          diasSelecionados: [],
        );
      }
      
      int dia = mm['Dia_Especifico'] ?? 0;
      mapaGrupos[chave]!.diasOriginais[dia] = mm['Id'];
      
      if (mm['FrequenciaId'] != 1) {
        mapaGrupos[chave]!.diasSelecionados.add(dia);
      }
    }

    setState(() {
      _gruposExistentes = mapaGrupos.values.toList();
      _isLoading = false;
    });
  }

  void _adicionarNovaMicrometa() {
    setState(() => _micrometasNovas.add(MicrometaNova()));
  }

  void _removerNovaMicrometa(int index) {
    setState(() => _micrometasNovas.removeAt(index));
  }

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) return;

    for (var mm in _micrometasNovas) {
      if (mm.frequenciaId == 2 && mm.diasSemana.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione os dias da semana para a nova micrometa!')));
        return;
      }
      if (mm.frequenciaId == 3 && mm.diasMes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione os dias do mês para a nova micrometa!')));
        return;
      }
    }

    for (var grupo in _gruposExistentes) {
      if (grupo.frequenciaId == 2 && grupo.diasSelecionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione os dias da semana para "${grupo.descricao}"!')));
        return;
      }
      if (grupo.frequenciaId == 3 && grupo.diasSelecionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione os dias do mês para "${grupo.descricao}"!')));
        return;
      }
    }

    try {
      await _metaRepo.atualizar(widget.meta['Id'], _descricaoMetaController.text, _prazoController.text);

      // SOFT DELETE 
      for (var grupo in _gruposExistentes) {
        bool mudouFrequencia = grupo.frequenciaId != grupo.frequenciaOriginal;
        List<int?> diasAlvo = grupo.frequenciaId == 1 ? [null] : grupo.diasSelecionados;

        if (mudouFrequencia) {
          // Se a frequência mudou totalmente (ex: Diário para Semanal), inativa TODOS os IDs antigos 
          // para congelar o histórico, e insere os novos do zero.
          for (int idAntigo in grupo.diasOriginais.values) {
            await _micrometaRepo.inativar(idAntigo);
          }
          for (int? dia in diasAlvo) {
            await _micrometaRepo.inserir(Micrometa(metaId: widget.meta['Id'], frequenciaId: grupo.frequenciaId, descricao: grupo.descricao, diaEspecifico: dia));
          }
        } else {
          // Frequência é a mesma
          for (int? dia in diasAlvo) {
            int keyDia = dia ?? 0; // 0 é a chave interna usada pro diário
            if (grupo.diasOriginais.containsKey(keyDia)) {
              // Esse dia JÁ EXISTIA nessa frequência. Apenas atualiza
              int id = grupo.diasOriginais[keyDia]!;
              await _micrometaRepo.atualizarCompleto(id, grupo.descricao, grupo.frequenciaId, dia);
            } else {
              // Adicionou um dia novo que não tinha antes
              await _micrometaRepo.inserir(Micrometa(metaId: widget.meta['Id'], frequenciaId: grupo.frequenciaId, descricao: grupo.descricao, diaEspecifico: dia));
            }
          }
          
          // Arquiva os dias antigos que foram desmarcados na tela
          for (int keyDiaOriginal in grupo.diasOriginais.keys) {
            bool manteveDia = (grupo.frequenciaId == 1) || diasAlvo.contains(keyDiaOriginal);
            if (!manteveDia) {
              int idParaInativar = grupo.diasOriginais[keyDiaOriginal]!;
              await _micrometaRepo.inativar(idParaInativar);
            }
          }
        }
      }

      // Insere Micrometas Novas
      for (var temp in _micrometasNovas) {
        if (temp.frequenciaId == 1) {
          await _micrometaRepo.inserir(Micrometa(metaId: widget.meta['Id'], frequenciaId: 1, descricao: temp.descricao));
        } else if (temp.frequenciaId == 2) {
          for (var dia in temp.diasSemana) {
            await _micrometaRepo.inserir(Micrometa(metaId: widget.meta['Id'], frequenciaId: 2, descricao: temp.descricao, diaEspecifico: dia));
          }
        } else if (temp.frequenciaId == 3) {
          for (var dia in temp.diasMes) {
            await _micrometaRepo.inserir(Micrometa(metaId: widget.meta['Id'], frequenciaId: 3, descricao: temp.descricao, diaEspecifico: dia));
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meta salva com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  InputDecoration _construirDecoracao(String label, {IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.escuro),
      filled: true,
      fillColor: AppColors.branco,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.escuro) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.claro,
      appBar: AppBar(
        backgroundColor: AppColors.medio,
        title: const Text('Editar Meta', style: TextStyle(color: AppColors.escuro)),
        iconTheme: const IconThemeData(color: AppColors.escuro),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const Text('Dados da Meta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.escuro)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoMetaController,
                    decoration: _construirDecoracao('Descrição da Meta'),
                    validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prazoController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100), locale: const Locale('pt', 'BR'));
                      if (picked != null) setState(() => _prazoController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}");
                    },
                    decoration: _construirDecoracao('Prazo', suffixIcon: Icons.calendar_today),
                  ),
                  
                  const Divider(height: 48, thickness: 2, color: AppColors.medio),
                  
                  const Text('Micrometas Existentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.escuro)),
                  const SizedBox(height: 8),
                  const Text(
                    'Dica: Dias desmarcados ou frequências alteradas irão para o Histórico Arquivado na tela de detalhes.', 
                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),

                  ..._gruposExistentes.map((grupo) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.branco, border: Border.all(color: AppColors.medio), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: grupo.descricao,
                            onChanged: (val) => grupo.descricao = val,
                            decoration: _construirDecoracao('Descrição'),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: grupo.frequenciaId,
                            decoration: _construirDecoracao('Frequência'),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Diária')),
                              DropdownMenuItem(value: 2, child: Text('Semanal')),
                              DropdownMenuItem(value: 3, child: Text('Mensal')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                grupo.frequenciaId = val!;
                                grupo.diasSelecionados.clear(); 
                              });
                            }, 
                          ),
                          const SizedBox(height: 16),
                          if (grupo.frequenciaId == 2)
                            _buildMultiSeletorSemanal(grupo.diasSelecionados),
                          if (grupo.frequenciaId == 3)
                            _buildMultiSeletorMensal(grupo.diasSelecionados),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 48, thickness: 2, color: AppColors.medio),

                  const Text('Adicionar Novas Micrometas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.escuro)),
                  const SizedBox(height: 16),
                  
                  ..._micrometasNovas.asMap().entries.map((entry) {
                    int idx = entry.key;
                    MicrometaNova nova = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.branco, border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Nova Micrometa ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removerNovaMicrometa(idx)),
                            ],
                          ),
                          TextFormField(
                            onChanged: (val) => nova.descricao = val,
                            decoration: _construirDecoracao('Descrição'),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: nova.frequenciaId,
                            decoration: _construirDecoracao('Frequência'),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Diária')),
                              DropdownMenuItem(value: 2, child: Text('Semanal')),
                              DropdownMenuItem(value: 3, child: Text('Mensal')),
                            ],
                            onChanged: (val) => setState(() { nova.frequenciaId = val!; nova.diasSemana.clear(); nova.diasMes.clear(); }),
                          ),
                          const SizedBox(height: 16),
                          if (nova.frequenciaId == 2) _buildMultiSeletorSemanal(nova.diasSemana),
                          if (nova.frequenciaId == 3) _buildMultiSeletorMensal(nova.diasMes),
                        ],
                      ),
                    );
                  }),

                  TextButton.icon(
                    onPressed: _adicionarNovaMicrometa,
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    label: const Text('ADICIONAR NOVA MICROMETA', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _salvarEdicao,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.escuro, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('SALVAR ALTERAÇÕES', style: TextStyle(color: AppColors.branco, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMultiSeletorSemanal(List<int> listaDias) {
    const dias = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(dias.length, (i) {
        bool isSelected = listaDias.contains(i);
        return GestureDetector(
          onTap: () => setState(() { isSelected ? listaDias.remove(i) : listaDias.add(i); }),
          child: _bolinhaSelecao(dias[i], isSelected),
        );
      }),
    );
  }

  Widget _buildMultiSeletorMensal(List<int> listaDias) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: List.generate(31, (index) {
        int dia = index + 1;
        bool isSelected = listaDias.contains(dia);
        return GestureDetector(
          onTap: () => setState(() { isSelected ? listaDias.remove(dia) : listaDias.add(dia); }),
          child: _bolinhaSelecao(dia.toString(), isSelected),
        );
      }),
    );
  }

  Widget _bolinhaSelecao(String texto, bool isSelected) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? const Color(0xFFB57B8C) : const Color(0xFFEBE0E2)),
      alignment: Alignment.center,
      child: Text(texto, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF5A3A42), fontWeight: FontWeight.bold, fontSize: texto.length > 1 ? 12 : 14)),
    );
  }
}