# Guia de instalação

Este documento orienta a instalação do **Etiquetas** em um computador de usuário final.

---

## 1. Requisitos

### Sistema operacional

- Windows com ambiente gráfico.
- Linux com ambiente gráfico.

O projeto foi desenvolvido em Lazarus / Free Pascal e utiliza recursos gráficos do sistema operacional, banco SQLite e impressão padrão do sistema.

### Arquivos necessários

Para executar o sistema, a pasta de distribuição deve conter pelo menos:

```text
Etiquetas/
├── etiquetas.exe              # Windows
├── etiquetas                  # Linux, quando compilado para Linux
├── db/
│   └── etiqueta.db
├── sqlite/
│   └── win64/
│       └── sqlite3.dll
└── img/
```

A estrutura exata pode variar conforme a versão distribuída.

---

## 2. Instalação no Windows

### Passo 1 — Copiar o sistema

Copie a pasta do sistema para um local fixo, por exemplo:

```text
C:\Etiquetas\
```

Evite executar diretamente de pendrive ou pasta temporária.

### Passo 2 — Verificar o banco de dados

Confirme se existe o arquivo:

```text
C:\Etiquetas\db\etiqueta.db
```

Esse arquivo guarda produtos, endereços e registros usados na impressão.

### Passo 3 — Verificar a biblioteca SQLite

Confirme se existe a biblioteca SQLite, por exemplo:

```text
C:\Etiquetas\sqlite\win64\sqlite3.dll
```

Sem essa biblioteca o sistema pode exibir erro de conexão com banco.

### Passo 4 — Abrir o sistema

Execute:

```text
etiquetas.exe
```

No primeiro uso, abra a tela **Configuração** e confirme os caminhos do banco e da DLL SQLite.

---

## 3. Instalação no Linux

### Passo 1 — Copiar o sistema

Copie a pasta do sistema para um local de trabalho, por exemplo:

```bash
/opt/etiquetas/
```

ou

```bash
/home/usuario/etiquetas/
```

### Passo 2 — Permitir execução

Caso o executável não abra, aplique permissão:

```bash
chmod +x etiquetas
```

### Passo 3 — Conferir dependências gráficas e SQLite

O sistema depende de bibliotecas gráficas utilizadas pelo Lazarus/LCL e de acesso SQLite. Em distribuições Debian/Ubuntu, pode ser necessário instalar bibliotecas de SQLite:

```bash
sudo apt install sqlite3 libsqlite3-0
```

### Passo 4 — Abrir o sistema

Execute o binário compilado para Linux:

```bash
./etiquetas
```

---

## 4. Configuração inicial

Abra o menu **Configuração** e preencha:

| Campo | Finalidade |
|---|---|
| Banco de dados | Caminho do arquivo `etiqueta.db`. |
| Biblioteca SQLite | Caminho da biblioteca SQLite, principalmente `sqlite3.dll` no Windows. |
| Empresa | Nome da empresa usado em etiquetas de mala direta. |
| Endereço 1 | Primeira linha do endereço da empresa. |
| Endereço 2 | Segunda linha do endereço da empresa. |

Clique em **Salvar**.

O sistema grava essas informações no arquivo de configuração do usuário.

---

## 5. Banco de dados

O sistema usa SQLite. Isso significa que os dados ficam em um arquivo local, sem necessidade de servidor de banco de dados.

Arquivo padrão esperado:

```text
db/etiqueta.db
```

Recomendações:

- Faça backup periódico do arquivo `etiqueta.db`.
- Não apague o banco sem ter cópia de segurança.
- Feche o sistema antes de copiar ou substituir o banco.

---

## 6. Impressora

Antes de imprimir pelo Etiquetas, instale a impressora no sistema operacional.

Depois, no Etiquetas:

1. Acesse **Configuração**.
2. Use a opção de configuração de impressora, quando disponível.
3. Escolha a impressora padrão ou a impressora de etiquetas.
4. Faça um teste de impressão.

Para mais detalhes, consulte [Configuração de impressora](configuracao_impressora.md).

---

## 7. Primeira execução recomendada

Após instalar:

1. Abra o sistema.
2. Configure banco e SQLite.
3. Configure a impressora.
4. Importe um CSV pequeno de teste.
5. Selecione um item.
6. Imprima uma etiqueta.
7. Ajuste tamanho, margem e driver da impressora se necessário.

---

## 8. Atualização do sistema

Para atualizar:

1. Feche o Etiquetas.
2. Faça backup da pasta atual.
3. Faça backup do arquivo `db/etiqueta.db`.
4. Substitua o executável e arquivos do sistema.
5. Mantenha o banco antigo, salvo quando houver orientação de migração.
6. Abra o sistema e teste a impressão.
