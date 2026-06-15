import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/repositories/micrometa_repository.dart';
import '../data/repositories/historico_repository.dart';

class VerMetaScreen extends StatefulWidget {
  final Map<String, dynamic> meta;

  const VerMetaScreen({super.key, required this.meta});

  @override
  State<VerMetaScreen> createState() => _VerMetaScreenState();
}

class _VerMetaScreenState extends State<VerMetaScreen> {
  final MicrometaRepository _micrometaRepo = MicrometaRepository();
  final HistoricoRepository _historicoRepo = HistoricoRepository();

  List<Map<String, dynamic>> _micrometasAtivas = [];
  List<Map<String, dynamic>> _micrometasArquivadas = [];
  Map<int, int> _historicoCounts = {}; 
  Map<int, bool> _cumpridasHoje = {}; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    // Busca TODAS as micrometas (Ativas e Inativas)
    final micrometas = await _micrometaRepo.buscarTodasPorMeta(widget.meta['Id']);
    
    Map<int, int> counts = {};
    Map<int, bool> hoje = {};
    List<Map<String, dynamic>> ativas = [];
    List<Map<String, dynamic>> arquivadas = [];
    
    for (var mm in micrometas) {
      int id = mm['Id'];
      counts[id] = await _historicoRepo.contarCumprimentos(id);
      hoje[id] = await _historicoRepo.verificouHoje(id);

      if (mm['Ativo'] == 1) {
        ativas.add(mm);
      } else {
        // Só exibe no histórico arquivado se já foi cumprida alguma vez
        if (counts[id]! > 0) arquivadas.add(mm);
      }
    }

    setState(() {
      _micrometasAtivas = ativas;
      _micrometasArquivadas = arquivadas;
      _historicoCounts = counts;
      _cumpridasHoje = hoje;
      _isLoading = false;
    });
  }

  // Verifica se o dia atual corresponde ao dia agendado da micrometa
  bool _podeMarcarHoje(int frequenciaId, int? diaEspecifico) {
    if (frequenciaId == 1) return true; 

    DateTime hoje = DateTime.now();
    
    if (frequenciaId == 2) {
      int diaSemanaAtual = hoje.weekday == 7 ? 0 : hoje.weekday;
      return diaSemanaAtual == diaEspecifico;
    }
    
    if (frequenciaId == 3) {
      return hoje.day == diaEspecifico; 
    }
    
    return false;
  }

  Future<void> _toggleCumprimento(int micrometaId) async {
    bool jaCumpriuHoje = _cumpridasHoje[micrometaId] ?? false;

    if (jaCumpriuHoje) {
      await _historicoRepo.removerCumprimentoHoje(micrometaId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marcação de hoje removida.'), backgroundColor: AppColors.escuro),
      );
    } else {
      await _historicoRepo.registrarCumprimento(micrometaId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uhuul! Progresso registrado!'), backgroundColor: Colors.green),
      );
    }
    
    _carregarDados(); 
  }

  String _traduzirFrequencia(int freqId, int? diaEspecifico) {
    if (freqId == 1) return 'Diária';
    if (freqId == 2) {
      const dias = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      return 'Semanal (${diaEspecifico != null ? dias[diaEspecifico] : ''})';
    }
    if (freqId == 3) return 'Mensal (Dia $diaEspecifico)';
    return 'Desconhecida';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.claro,
      appBar: AppBar(
        backgroundColor: AppColors.medio,
        title: const Text('Detalhes da Meta', style: TextStyle(color: AppColors.escuro)),
        iconTheme: const IconThemeData(color: AppColors.escuro),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.escuro))
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // CARD DA META PRINCIPAL
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.escuro, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('META PRINCIPAL', style: TextStyle(color: AppColors.claro, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.meta['Descricao'], style: const TextStyle(color: AppColors.branco, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.branco, size: 16),
                          const SizedBox(width: 8),
                          Text('Prazo: ${widget.meta['Prazo']}', style: const TextStyle(color: AppColors.branco, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // MICROMETAS ATIVAS
                const Text('Suas Micrometas Ativas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.escuro)),
                const SizedBox(height: 16),

                ..._micrometasAtivas.map((mm) {
                  int id = mm['Id'];
                  int vezesCumprida = _historicoCounts[id] ?? 0;
                  bool feitaHoje = _cumpridasHoje[id] ?? false;
                  bool diaCorreto = _podeMarcarHoje(mm['FrequenciaId'], mm['Dia_Especifico']);
                  
                  return Card(
                    color: feitaHoje ? const Color(0xFFE8F5E9) : AppColors.branco,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: feitaHoje ? Colors.green : AppColors.medio, width: feitaHoje ? 2 : 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(mm['Descricao'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.escuro)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Frequência: ${_traduzirFrequencia(mm['FrequenciaId'], mm['Dia_Especifico'])}', style: TextStyle(color: diaCorreto ? AppColors.escuro : Colors.grey)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: vezesCumprida > 0 ? Colors.green.withOpacity(0.2) : AppColors.medio.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🎯 Cumprida $vezesCumprida vezes',
                                style: TextStyle(
                                  color: vezesCumprida > 0 ? Colors.green[800] : AppColors.escuro,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          feitaHoje ? Icons.check_circle : (diaCorreto ? Icons.radio_button_unchecked : Icons.lock_clock),
                          size: 36, 
                          color: feitaHoje ? Colors.green : (diaCorreto ? AppColors.escuro : Colors.grey),
                        ),
                        onPressed: diaCorreto 
                          ? () => _toggleCumprimento(id) 
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Você só pode marcar esta meta no dia agendado!')),
                              );
                            },
                      ),
                    ),
                  );
                }),

                // SEÇÃO DE HISTÓRICO ARQUIVADO (Só aparece se houver histórico de metas editadas)
                if (_micrometasArquivadas.isNotEmpty) ...[
                  const Divider(height: 48, thickness: 2, color: AppColors.medio),
                  const Text('Histórico de Configurações Anteriores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  ..._micrometasArquivadas.map((mm) {
                    int id = mm['Id'];
                    int vezesCumprida = _historicoCounts[id] ?? 0;
                    
                    return Card(
                      color: const Color(0xFFF5F5F5), 
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(mm['Descricao'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Frequência antiga: ${_traduzirFrequencia(mm['FrequenciaId'], mm['Dia_Especifico'])}', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text('🔒 Cumprida $vezesCumprida vezes no passado', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}