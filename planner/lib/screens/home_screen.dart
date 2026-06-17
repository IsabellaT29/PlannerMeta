import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import '../theme/app_colors.dart';
import '../data/repositories/micrometa_repository.dart';
import '../data/repositories/historico_repository.dart';
import 'meta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MicrometaRepository _micrometaRepo = MicrometaRepository();
  final HistoricoRepository _historicoRepo = HistoricoRepository();

  List<Map<String, dynamic>> _rotinaDiariaAgrupada = [];
  Map<int, bool> _cumpridasHoje = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarRotinaDiaria();
  }

  Future<void> _carregarRotinaDiaria() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Busca todos os registros brutos do SQLite
      final rotinasBrutas = await _micrometaRepo.buscarTodasAtivasGerais(); 
      
      // 2. Mapas auxiliares para estruturar e agrupar com segurança sem estourar tipo nulo
      Map<int, Map<String, dynamic>> agrupado = {};
      Map<int, bool> cumpridas = {};

      for (var mm in rotinasBrutas) {
        int id = mm['Id'];
        int metaId = mm['MetaId'];
        int frequenciaId = mm['FrequenciaId'];
        int? diaEspecifico = mm['Dia_Especifico'];
        
        // Verifica o estado de cumprimento de hoje
        bool jaCumpriuHoje = await _historicoRepo.verificouHoje(id);
        cumpridas[id] = jaCumpriuHoje;

        // Se a meta ainda não está mapeada, inicializa ela definindo explicitamente 'DiasAtivos' como uma lista real
        if (!agrupado.containsKey(metaId)) {
          agrupado[metaId] = {
            'Id': id,
            'MetaId': metaId,
            'Descricao': mm['Descricao'],
            'FrequenciaId': frequenciaId,
            'DiasAtivos': <int>[], // Lista instanciada com tipo estrito para evitar o erro de Null
          };
        }

        List<int> diasAtivosDaMeta = agrupado[metaId]!['DiasAtivos'] as List<int>;

        // Alimenta a lista de dias com base na regra de frequência
        if (frequenciaId == 1) {
          // Diária: Ativa de Domingo (0) a Sábado (6)
          agrupado[metaId]!['DiasAtivos'] = [0, 1, 2, 3, 4, 5, 6];
        } else if (frequenciaId == 2 && diaEspecifico != null) {
          // Semanal: Adiciona o dia específico se ele não estiver na lista
          if (!diasAtivosDaMeta.contains(diaEspecifico)) {
            diasAtivosDaMeta.add(diaEspecifico);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _rotinaDiariaAgrupada = agrupado.values.toList();
        _cumpridasHoje = cumpridas;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCumprimento(int micrometaId) async {
    bool jaCumpriuHoje = _cumpridasHoje[micrometaId] ?? false;

    if (jaCumpriuHoje) {
      await _historicoRepo.removerCumprimentoHoje(micrometaId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marcação de hoje removida.'), 
          backgroundColor: AppColors.escuro,
        ),
      );
    } else {
      await _historicoRepo.registrarCumprimento(micrometaId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uhuul! Progresso registrado!'), 
          backgroundColor: Colors.green,
        ),
      );
    }
    _carregarRotinaDiaria(); 
  }

  Widget _buildRotinaCard(Map<String, dynamic> mm) {
    int id = mm['Id'];
    bool feitaHoje = _cumpridasHoje[id] ?? false;
    List<int> diasAtivos = mm['DiasAtivos'] as List<int>;
    
    // Converte o weekday do Dart (1:Seg..7:Dom) para o padrão do seu seletor (0:Dom..1:Seg..6:Sáb)
    int hojeNoPadraoSeletor = DateTime.now().weekday == 7 ? 0 : DateTime.now().weekday;
    
    // Permite marcar se for diária (1) ou se o dia atual está contido na lista de agendamentos estruturada
    bool diaCorreto = mm['FrequenciaId'] == 1 || diasAtivos.contains(hojeNoPadraoSeletor);

    // Lista de exibição começando por Domingo para sincronizar visualmente
    final List<String> diasDaSemanaHome = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsividade: Se a largura da tela for menor que 620px, adapta para o Mobile
        bool isMobile = constraints.maxWidth < 620;

        // Componente das bolinhas isolado com Wrap para evitar estouro de layout
        Widget listaBolinhas = Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(7, (i) {
            bool pertenceAoAgendamento = mm['FrequenciaId'] == 1 || diasAtivos.contains(i);
            bool diaFoiCumprido = (i == hojeNoPadraoSeletor) && feitaHoje;

            Color corFundo;
            Color corTexto;

            if (pertenceAoAgendamento) {
              if (diaFoiCumprido) {
                corFundo = const Color(0xFFB07A8A); 
                corTexto = Colors.white;
              } else {
                corFundo = const Color(0xFFF3EAE9);
                corTexto = AppColors.escuro.withAlpha(180);
              }
            } else {
              corFundo = Colors.transparent;
              corTexto = AppColors.escuro.withAlpha(50);
            }
            
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: corFundo,
                border: pertenceAoAgendamento && !diaFoiCumprido
                    ? Border.all(color: const Color(0xFFB07A8A).withAlpha(100), width: 1)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                diasDaSemanaHome[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
            );
          }),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.branco,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Checkbox principal
                  InkWell(
                    onTap: diaCorreto 
                        ? () => _toggleCumprimento(id) 
                        : () {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Esta meta não está agendada para hoje!')),
                            );
                          },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: feitaHoje ? AppColors.escuro : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.escuro, width: 2),
                      ),
                      child: feitaHoje 
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Descrição da Meta protegida por Expanded para não esmagar no celular
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mm['Descricao'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.escuro,
                            decoration: feitaHoje ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Meta: Código ${mm['MetaId']}', 
                          style: TextStyle(
                            fontSize: 13, 
                            color: AppColors.escuro.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Se for tela larga (Desktop/Web), exibe na direita
                  if (!isMobile) ...[
                    const SizedBox(width: 16),
                    listaBolinhas,
                  ],
                ],
              ),
              
              // Se for tela fina (Mobile), joga as bolinhas para baixo elegantemente
              if (isMobile) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 42), // Alinha perfeitamente com o início do texto
                  child: listaBolinhas,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.claro,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: AppColors.medio,
        iconTheme: const IconThemeData(color: AppColors.escuro),
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                _carregarRotinaDiaria();
              },
              child: const Text(
                'Home',
                style: TextStyle(
                  color: AppColors.escuro, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, 
                ),
              ),
            ),
            const SizedBox(width: 5),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MetasScreen(usuarioId: 1), 
                  ),
                ).then((_) => _carregarRotinaDiaria()); // Atualiza ao voltar da tela de Metas
              },
              child: const Text(
                'Metas',
                style: TextStyle(
                  color: AppColors.escuro, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB07A8A)))
          : _rotinaDiariaAgrupada.isEmpty
              ? const Center(child: Text('Nenhuma micrometa cadastrada para hoje.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rotinaDiariaAgrupada.length,
                  itemBuilder: (context, index) {
                    return _buildRotinaCard(_rotinaDiariaAgrupada[index]);
                  },
                ),
    );
  }
}