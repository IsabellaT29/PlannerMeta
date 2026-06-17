import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/repositories/meta_repository.dart';
import 'login_screen.dart'; 
import 'criar_meta_screen.dart'; 
import 'ver_meta_screen.dart';
import 'editar_meta_screen.dart';

class MetasScreen extends StatefulWidget {
  final int usuarioId;

  const MetasScreen({super.key, required this.usuarioId});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MetaRepository _metaRepository = MetaRepository();
  
  List<Map<String, dynamic>> _metas = [];
  List<Map<String, dynamic>> _metasFiltradas = [];
  bool _isLoading = true;
  String _nomeUsuario = "Carregando..."; // Guardará o nome do usuário logado

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carrega o nome do usuário e as metas em paralelo
  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoading = true);
    try {
      final nome = await _metaRepository.buscarNomeUsuario(widget.usuarioId);
      final metasResult = await _metaRepository.buscarMetasPorUsuario(widget.usuarioId);
      
      setState(() {
        _nomeUsuario = nome;
        _metas = metasResult;
        _metasFiltradas = metasResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _carregarMetas() async {
    final result = await _metaRepository.buscarMetasPorUsuario(widget.usuarioId);
    setState(() {
      _metas = result;
      _metasFiltradas = result;
    });
  }

  void _filtrarMetas(String query) {
    if (query.isEmpty) {
      setState(() {
        _metasFiltradas = _metas;
      });
    } else {
      setState(() {
        _metasFiltradas = _metas.where((meta) {
          final descricao = meta['Descricao'].toString().toLowerCase();
          return descricao.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  // modal de confirmação antes de deletar
  Future<void> _deletarMeta(int id) async {
    // 1. Exibe o alerta e aguarda a resposta do usuário
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.branco,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Excluir Meta', style: TextStyle(color: AppColors.escuro, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja excluir? Todo o histórico será perdido no processo.',
            style: TextStyle(color: AppColors.escuro, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Retorna 'false' ao fechar
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.escuro, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true), // Retorna 'true' ao confirmar
              child: const Text('EXCLUIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ) ?? false; // Se o usuário clicar fora do modal para fechar, assume como 'false'

    // 2. Se o usuário cancelou, não faz nada
    if (!confirmar) return;

    // 3. Se confirmou, executa a exclusão no banco de dados
    await _metaRepository.deletar(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta deletada com sucesso!'),
          backgroundColor: AppColors.escuro,
        ),
      );
    }
    _carregarMetas();
  }

  // Função para executar a ação de logout
  void _efetuarLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  InputDecoration _construirDecoracao(String label, IconData icone) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.escuro),
      prefixIcon: Icon(icone, color: AppColors.escuro),
      filled: true,
      fillColor: AppColors.branco,
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
      // Customização da AppBar para agir como uma Nav Bar completa
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove botão de voltar automático
        backgroundColor: AppColors.medio,
        iconTheme: const IconThemeData(color: AppColors.escuro),
        title: Row(
          children: [
            // Link Home
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Home',
                style: TextStyle(color: AppColors.escuro, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 5),
            // Link Metas
            TextButton(
              onPressed: _carregarMetas,
              child: const Text(
                'Metas',
                style: TextStyle(
                  color: AppColors.escuro, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline
                ),
              ),
            ),
          ],
        ),
        actions: [
                    
          // Menu Dropdown do Perfil do Usuário envolto em Flexible para evitar quebra por nomes longos
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _efetuarLogout();
              }
            },
            offset: const Offset(0, 50),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Garante que a linha ocupe apenas o espaço necessário
                children: [
                  // Flexible impede que o nome do usuário "empurre" a tela para fora se for muito comprido
                  Flexible(
                    child: Text(
                      _nomeUsuario,
                      overflow: TextOverflow.ellipsis, // Se o nome for gigante, ele coloca "..." no final ao invés de quebrar a tela
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.escuro, 
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.account_circle, size: 28, color: AppColors.escuro),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile_info',
                enabled: false,
                child: Text(
                  'Logado como:\n$_nomeUsuario',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Deslogar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),      
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filtrarMetas,
              style: const TextStyle(color: AppColors.escuro),
              decoration: _construirDecoracao('Pesquisar metas...', Icons.search),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CriarMetaScreen(usuarioId: widget.usuarioId),
                  ),
                ).then((_) => _carregarMetas()); // Também recarrega caso crie uma nova e volte
              },
              icon: const Icon(Icons.add, color: AppColors.branco),
              label: const Text(
                'CRIAR NOVA META',
                style: TextStyle(fontSize: 16, color: AppColors.branco, fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return const Color(0xFF6B2036);
                    }
                    return AppColors.escuro;
                  },
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.escuro))
                  : _metasFiltradas.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma meta encontrada.',
                            style: TextStyle(color: AppColors.escuro, fontSize: 16),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.branco,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.medio),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AppColors.medio.withValues(alpha:0.3)),
                                columns: const [
                                  DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.escuro))),
                                  DataColumn(label: Text('Prazo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.escuro))),
                                  DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.escuro))),
                                ],
                                rows: _metasFiltradas.map((meta) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(meta['Descricao'], style: const TextStyle(color: AppColors.escuro))),
                                      DataCell(Text(meta['Prazo'], style: const TextStyle(color: AppColors.escuro))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility, color: Colors.blue),
                                              tooltip: 'Ver',
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => VerMetaScreen(meta: meta),
                                                  ),
                                                ).then((_) => _carregarMetas()); // Recarrega a lista ao voltar
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.orange),
                                              tooltip: 'Editar',
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditarMetaScreen(meta: meta),
                                                  ),
                                                ).then((_) => _carregarMetas()); // Recarrega a lista se houver edição
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Deletar',
                                              onPressed: () => _deletarMeta(meta['Id']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}