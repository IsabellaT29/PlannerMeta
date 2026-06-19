<h1 align="center">🎯 PlannerMeta - Gestão de Metas Pessoais</h1>

---

## 📖 Sobre o Projeto

O **PlannerMeta** é um aplicativo intuitivo e moderno desenvolvido para a gestão de metas pessoais. Este projeto foi concebido como parte prática da disciplina de **Desenvolvimento para Dispositivos Móveis**.

O principal objetivo do PlannerMeta é facilitar o controle de metas pessoais, entregando uma interface simples, limpa, fofa e altamente funcional que auxilie as pessoas a organizarem suas metas, ter controle do progresso, sem poluição visual.

---

## 🚀 Principais Funcionalidades

O sistema centraliza ferramentas indispensáveis para o controle de suas metas:

* **Organização Estruturada (CRUD):** Criação, visualização, edição e exclusão de metas de forma simples e rápida.
* **Status de Progresso:** Controle visual do cumprimento das metas.
* **Histórico de Micrometas:** Uma vez incluídas no app, o histórico de alterações fica visível para o usuário.

---

### 🎬 Link do Youtube

  No Link abaixo, veja uma demonstração prática do aplicativo:
</p>

---

## 🛠️ Tecnologias Utilizadas

A arquitetura do projeto foi desenvolvida utilizando tecnologias consolidadas do mercado:

* **Framework:** 3.44.1.
* **Linguagem** Dart v3.3.
* **Banco de Dados:** SQLite (via sqflite: ^2.4.3)

---

## ⚙️ Configuração e Execução do Projeto

Siga os passos abaixo para configurar e executar o app em seu ambiente local.

### 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

* **Flutter SDK** (na versão especificada acima ou superior)
* **Git**
* Um emulador configurado (Android/iOS) ou um dispositivo físico conectado em modo de depuração.

### Passo a Passo

---

### 📥 1. Clone o Repositório

Abra o terminal do seu computador e execute o comando:

git clone [http(https://github.com/IsabellaT29/PlannerMeta.git)

---

### ⚙️ 2. Acessar a pasta do projeto

```bash
cd PlannerMeta/planner
```

---

### 📦 3. Instale as Dependências

```bash
flutter pub get
```

---

### 🔑 4. Executar a aplicação:

```bash
flutter run
```

---

## 🛠️ Guia de Configuração e Instalação Para Rodar Diretamente no seu Dispositivo Físico via Wi-Fi

Siga os passos abaixo para configurar o ambiente do Flutter, instalar as dependências e rodar o projeto diretamente no seu dispositivo físico via Wi-Fi.

---

### 1. Configurando o Flutter e Dependências Básicas

Se o comando `flutter` não for reconhecido no seu terminal, siga os passos para a instalação manual:

1. Acesse a [Documentação Oficial do Flutter](https://docs.flutter.dev/install/manual) e baixe o arquivo `.zip` do SDK.
2. Descompacte a pasta diretamente na raiz do seu sistema (ex: `C:\flutter`).
3. No menu iniciar do Windows, pesquise por **"Editar as variáveis de ambiente do sistema"**.
4. Clique em **Variáveis de Ambiente**, localize a variável `Path` na seção "Variáveis de usuário" (ou do sistema) e clique em **Editar**.
5. Clique em **Novo** e adicione o caminho do executável do Flutter: `C:\flutter\bin`.
6. Reinicie o seu VS Code para que o terminal reconheça as alterações.

Com o Flutter funcionando, acesse a pasta do projeto (`cd PlannerMeta/planner`) e instale as dependências de banco de dados e segurança executando:
```bash
flutter pub add sqflite path crypto sqflite_common_ffi_web
```
---

### 2. Configurando a Depuração sem Fio (ADB Wireless)

Para rodar o projeto com o banco de dados local SQLite de forma física, o método mais estável é a depuração via Wi-Fi usando as ferramentas do Android (Platform Tools).

**Pré-requisitos no Computador e Celular**

- Garanta que o computador e o celular estejam conectados na mesma rede Wi-Fi.

- Caso use um dispositivo Samsung, instale o Driver USB oficial da Samsung no computador.

- Baixe o pacote Android SDK Platform Tools.

- Extraia o arquivo .zip e mova a pasta platform-tools para a raiz do seu Disco C:\ (ficando em C:\platform-tools).

---

**Ativando o Modo Desenvolvedor no Celular**

- Vá em Configurações > Sobre o telefone > Informações do software e clique 7 vezes em Número de compilação até ativar o modo desenvolvedor.

- Volte ao menu principal de Configurações, entre em Opções do desenvolvedor e ative a Depuração por Wi-Fi.

---

### 3. Pareando e Conectando o Dispositivo via Terminal

Com a tela de Depuração por Wi-Fi aberta no celular, siga este fluxo rigorosamente sem fechar a aba do aparelho:

**Passo 1: Parear o dispositivo**

  1. Clique em "Parear o dispositivo com código de pareamento". O Android exibirá o Endereço IP e porta junto com um Código de pareamento por Wi-Fi.

  2. No terminal do VS Code, execute o comando de pareamento substituindo pelos dados da sua tela:
      & "C:\platform-tools\adb.exe" pair SEU_IP:PORTA_DE_PAREAMENTO

  3. O terminal solicitará o código. Digite o código de 6 dígitos exibido no celular e pressione Enter.

**Passo 2: Conectar o dispositivo**

  1. Assim que o pareamento for concluído com sucesso, note que o Android altera a porta na tela principal da Depuração por Wi-Fi (a porta de conexão é diferente da porta de pareamento).

  2. Utilize o comando connect apontando para o IP e a nova porta exibida na tela principal:
    & "C:\platform-tools\adb.exe" connect SEU_IP:NOVA_PORTA

  3. O terminal deverá exibir a mensagem connected to... e o celular mostrará o status "Conectados no momento".

  ⚠️ Nota de Resolução de Problemas: Se o comando flutter run ainda assim não listar o seu celular, copie todo o conteúdo da pasta platform-tools do seu C:\ e cole dentro do diretório padrão do Android SDK da sua máquina (geralmente localizado em C:\Users\SEU_USUARIO\AppData\Local\Android\Sdk).

---
  
**4. Executando o Projeto**

  Com o dispositivo devidamente conectado e listado pelo Flutter, execute:
  
  flutter run

  
### ✅ Pronto!

Após concluir todos os passos, o aplicativo estará disponível.

Agora você já pode cadastrar suas metas e controlar seu progresso!

<br>

## 👨‍💻 Desenvolvedores

<p align="center">
  Desenvolvido com dedicação por:
</p>

<table align="center">
  <tr>
    <td align="center">
      <a href="https://github.com/GlendaArruda">
        <img src="https://github.com/GlendaArruda.png" width="120px;" alt="Glenda Kelly"/><br>
        <sub><b>Glenda Kelly</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/IsabellaT29">
        <img src="https://github.com/IsabellaT29.png" width="120px;" alt="Isabella Tereza"/><br>
        <sub><b>Isabella Tereza</b></sub>
      </a>
    </td>
    <td align="center">


