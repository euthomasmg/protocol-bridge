# Guia de estudos — C, C++, Java, CEN/XFS e J/XFS

## Objetivo do projeto

Estudar C, C++ e Java com foco no uso das APIs de CEN/XFS e J/XFS para comunicar com dispositivos de hardware. Aprender a desenvolver aplicações que abrem serviços, consultam capacidades e estado, executam operações e tratam resultados, eventos e erros.

O eixo principal do roteiro é a API usada pela aplicação. SPI, Service Provider, Device Service, drivers e SDKs entram como contexto de arquitetura para compreender o caminho até o hardware. Implementar essas camadas é um aprofundamento opcional.

O código atual em `src/main.cpp` é um primeiro exercício de C++. As etapas abaixo descrevem o roteiro de aprendizado; ainda não representam funcionalidades implementadas.

## 1. Vocabulário e mapa das camadas

| Termo | Significado no estudo |
| --- | --- |
| CEN/XFS | Especificações de interfaces para acesso a serviços e periféricos financeiros, como leitores de cartão e impressoras. O foco aqui é o XFS clássico para Windows. |
| J/XFS | J/eXtensions for Financial Services: arquitetura de acesso a dispositivos financeiros para a plataforma Java. Tem interfaces e modelo próprios. |
| API | Application Programming Interface: contrato usado pela aplicação para solicitar operações. |
| SPI | Service Provider Interface: contrato que o provedor implementa para se integrar à infraestrutura. Aqui, SPI significa isso, e não o barramento eletrônico Serial Peripheral Interface. |
| Service Provider (SP) | Implementação que atende às solicitações do CEN/XFS e integra o serviço ou dispositivo. |
| XFS Manager | Componente que encaminha solicitações da aplicação ao provedor apropriado. |
| Device Control / Device Manager | Elementos de controle e gerenciamento usados pela aplicação no J/XFS. |
| Device Service | Camada do J/XFS que fornece acesso ao dispositivo. |
| Driver / SDK | Recursos do fabricante ou do sistema operacional que podem ser usados pelo provedor para acessar o equipamento. |
| ABI | Contrato binário: convenções de chamada, tipos, layout de estruturas e símbolos exportados que permitem integrar módulos compilados. |

### CEN/XFS: visão simplificada

```text
Aplicação
    | usa a API
XFS Manager
    | chama a SPI
Service Provider — implementação que atende às chamadas
    | usa a integração oferecida pelo fabricante
Driver / SDK / comunicação com o dispositivo
    |
Hardware
```

Na nomenclatura do CEN/XFS, funções `WFS...` pertencem à API, `WFP...` à SPI e `WFM...` aos serviços de suporte/configuração do Manager. A especificação define o contrato; o acesso específico ao equipamento depende da implementação do provedor. [Referência oficial de API/SPI](https://www.cencenelec.eu/media/CEN-CENELEC/AreasOfWork/CEN%20sectors/Digital%20Society/CWA%20Download%20Area/XFS/16926-1.pdf).

**Desenvolver para a SPI** significa implementar o provedor que cumpre esse contrato: receber operações, executá-las pela integração disponível e entregar os resultados esperados. A SPI é uma interface; o SP é o módulo que a implementa. Isso não implica necessariamente escrever um driver do sistema operacional.

### J/XFS: visão simplificada

```text
Aplicação Java
    |
Device Control + Device Manager
    |
Comunicação, quando necessária
    |
Device Service — implementação que acessa o dispositivo
    |
Integração com o dispositivo
    |
Hardware
```

O J/XFS separa o controle usado pela aplicação do serviço que acessa o equipamento. Pode haver comunicação intermediária, e o serviço pode recorrer a código nativo. Esse desenho tem contratos próprios: não basta renomear as funções de um SP CEN/XFS para obter um Device Service J/XFS. [Arquitetura oficial do J/XFS](https://www.cencenelec.eu/media/CEN-CENELEC/AreasOfWork/CEN%20sectors/Digital%20Society/CWA%20Download%20Area/J-XFS/CWA_16008_2009/cwa16008-01-2009-aug.pdf).

## 2. C: fundamentos para interfaces nativas

### O que estudar

- Variáveis, tipos, operadores, condições, laços e funções.
- Ponteiros, endereços, indireção e passagem de dados por ponteiro.
- Arrays, strings terminadas em zero e buffers binários.
- `struct`, `enum`, `typedef` e ponteiros para funções.
- Alocação e liberação de memória; propriedade e tempo de vida dos dados.
- Tamanhos numéricos, alinhamento, padding e interpretação de bytes.
- Cabeçalhos `.h`, fontes `.c`, compilação e ligação.
- Códigos de retorno e parâmetros de saída.

### Prática

Criar um dispositivo simulado com funções para abrir, consultar estado, executar uma operação e fechar. Representar o estado com uma estrutura e devolver erros previsíveis para operações inválidas.

**Critério de aprendizado:** explicar quem criou cada buffer, quem pode acessá-lo e quem deve liberá-lo.

## 3. C++: implementação de aplicações que usam APIs nativas

### O que estudar

- Fundamentos da linguagem e diferenças em relação a C.
- Classes, interfaces abstratas, composição e polimorfismo.
- Referências, `const`, strings e coleções da biblioteca padrão.
- RAII, destrutores e ponteiros inteligentes para administrar recursos.
- Integração com interfaces C: `extern "C"`, símbolos e fronteiras de exceções.
- DLLs, funções exportadas, convenções de chamada e compatibilidade de arquitetura.
- Threads, mutexes, filas de trabalho e encerramento de tarefas.
- Máquina de estados para modelar abertura, disponibilidade, operação e falha.
- Logs e depuração de problemas de memória e concorrência.

### Ponto de partida no código atual

`src/main.cpp` soma os valores de 1 a 3 e imprime os totais acumulados: `1`, `3` e `6`. Estudar `main`, `for`, escopo, `+=`, `std::cout` e quebra de linha. Depois, extrair a soma para uma função e comparar uma implementação em C com uma em C++.

### Prática

Criar um cliente C++ que consome a interface C do simulador e encapsula abertura, operações e fechamento com RAII. Depois, aplicar essa organização ao consumo da API CEN/XFS.

**Critério de aprendizado:** conseguir fechar o dispositivo e liberar recursos também quando uma operação falha.

## 4. Java: base para J/XFS

### O que estudar

- Tipos, controle de fluxo, métodos, classes e interfaces.
- Encapsulamento, composição e implementação de contratos.
- Exceções, coleções e generics.
- Eventos, listeners e execução assíncrona.
- Threads, executores, sincronização e cancelamento.
- Ciclo de vida de recursos e encerramento explícito.
- Compilação, classpath, dependências, JARs e depuração.
- JNI e integração com bibliotecas nativas, caso o caminho escolhido exija isso.

### Prática

Criar uma interface Java de dispositivo e uma implementação simulada. Solicitar uma operação e receber sua conclusão por evento, incluindo um caso de falha.

**Critério de aprendizado:** explicar a diferença entre uma chamada aceita e uma operação concluída.

## 5. CEN/XFS: consumir a API na aplicação

Usar a referência oficial de API/SPI e a especificação da classe de dispositivo escolhida. Fixar a versão de estudo antes de usar cabeçalhos, estruturas e exemplos.

### Perguntas que o estudo deve responder

- Como a aplicação encontra e abre um serviço lógico?
- Como o Manager seleciona e chama o provedor?
- Qual é o ciclo de vida de uma sessão?
- Como consultar estado e capacidades?
- Como executar comandos e receber sua conclusão?
- Como registrar interesse e receber eventos na aplicação?
- Como tratar cancelamento, timeout e acesso concorrente?
- Quem é responsável por cada estrutura e buffer?
- Como negociar versões e diagnosticar incompatibilidades?
- Quais responsabilidades pertencem ao Manager, ao SP e ao driver?

### Prática

Escolher uma classe de dispositivo e desenvolver uma aplicação cliente: inicializar o ambiente, abrir um serviço lógico, consultar estado e capacidades, executar uma operação, tratar resultados e eventos, liberar os recursos e encerrar a sessão. Usar um provedor ou simulador compatível disponível no laboratório.

**Critério de aprendizado:** distinguir comportamento exigido pela especificação de uma escolha interna de implementação.

## 6. J/XFS: controle, serviço e eventos

Usar a arquitetura base e a especificação da classe escolhida como referências. Identificar também quais bibliotecas e qual implementação estarão disponíveis para o laboratório.

### O que investigar

- Responsabilidades de Device Control, Device Manager e Device Service.
- Descoberta, configuração, abertura e encerramento do dispositivo.
- Operações, resultados, estados e notificações.
- Relação entre o identificador de uma operação e seu evento de conclusão.
- Comportamento em falhas e disputa por recursos.
- Necessidade de comunicação entre processos ou de integração nativa.

### Prática

Desenvolver uma aplicação Java que utiliza as interfaces J/XFS disponíveis no laboratório para obter um dispositivo, consultar estado, solicitar uma operação e receber eventos. Comparar esse fluxo com o cliente CEN/XFS. Usar uma implementação ou simulador compatível; interfaces criadas para exercícios devem ser identificadas como didáticas.

## 7. Comunicação com hardware pela API

### O que aprender

- Ler documentação de um equipamento e reconhecer sua interface de acesso.
- Distinguir chamada de SDK, acesso via driver e protocolo de comunicação.
- Entender comandos, respostas, eventos e estados do dispositivo.
- Trabalhar com buffers, codificação e mensagens incompletas quando o transporte exigir.
- Selecionar operações da API conforme as capacidades informadas pelo dispositivo.
- Interpretar resultados e erros retornados à aplicação.
- Definir timeout, cancelamento e recuperação de desconexões.
- Evitar que operações simultâneas deixem o dispositivo em estado incoerente.
- Registrar o fluxo de uma solicitação para conseguir depurá-la.

A interface física, o driver e o SDK dependem do equipamento escolhido. Serial, USB e rede são possibilidades a investigar conforme essa escolha.

### Exercício central

Construir uma aplicação cliente com operações de abertura, consulta de estado, execução e fechamento. Exercitar indisponibilidade, demora e desconexão com um simulador. Depois, repetir o cenário com um dispositivo real usando a infraestrutura compatível disponível.

### Aprofundamento opcional em SPI

Estudar como um provedor traduz comandos padronizados em operações do fabricante. Implementar um SP ou Device Service pode ser um exercício posterior, depois de dominar o consumo das APIs.

## 8. Etapas práticas do projeto

| Etapa | Entrega | Evidência de aprendizado |
| --- | --- | --- |
| 1 | Exercícios básicos em C, C++ e Java | Explicar, compilar e depurar cada programa. |
| 2 | Simulador em C | Controlar estados, buffers e códigos de erro. |
| 3 | Cliente C++ para a interface C do simulador | Demonstrar consumo da API e liberação de recursos. |
| 4 | Simulador Java com eventos | Correlacionar solicitação, conclusão e falha. |
| 5 | Mapa de uma operação CEN/XFS | Identificar cada camada e seu contrato. |
| 6 | Aplicação cliente CEN/XFS | Abrir serviço, consultar estado, executar operação e tratar eventos. |
| 7 | Aplicação cliente J/XFS | Usar as interfaces Java e acompanhar operações e eventos. |
| 8 | Integração com hardware | Executar o cenário escolhido e diagnosticar falhas. |
| 9, opcional | Ponte entre os dois ambientes | Documentar equivalências e diferenças entre os contratos. |

A ponte entre CEN/XFS e J/XFS é uma possibilidade de exercício posterior. Estudar as duas tecnologias não exige implementar essa ponte desde o início.

## 9. Ambiente, verificação e documentação

- Registrar compiladores, JDK, ferramentas de build e comandos reproduzíveis.
- Definir versões das especificações, cabeçalhos, bibliotecas e SDKs utilizados.
- Conferir compatibilidade entre arquitetura do processo, DLLs e dependências nativas.
- Usar debugger, logs e rastreamento de operações.
- Verificar sucesso, entrada inválida, estado inválido, timeout, cancelamento e fechamento durante uma operação.
- Usar Git com commits pequenos e registrar decisões de estudo.
- Separar exemplos didáticos de implementações que pretendem seguir o padrão.

## 10. Definições ainda pendentes

- Classe e modelo de dispositivo a estudar primeiro.
- Versão de CEN/XFS e de J/XFS que será usada.
- Disponibilidade de Manager, bibliotecas, SDK, documentação e simuladores.
- Forma de acesso ao equipamento e necessidade de integração nativa em Java.
- Outras palavras-chave mencionadas no contexto de trabalho, quando forem identificadas.

Essas escolhas refinam os exercícios de integração. Os estudos de linguagem e os simuladores podem começar antes delas.

## Checklist de progresso

- [ ] Explicar a diferença entre API, SPI, SP, driver e SDK.
- [ ] Desenhar o caminho entre aplicação e hardware nos dois ambientes.
- [ ] Entender ponteiros, buffers e memória em C.
- [ ] Entender recursos, DLLs e integração C/C++.
- [ ] Entender interfaces, eventos e concorrência em Java.
- [ ] Compilar e depurar exemplos nas três linguagens.
- [ ] Construir e exercitar um dispositivo simulado.
- [ ] Escolher versões e classe de dispositivo.
- [ ] Acompanhar uma operação na especificação CEN/XFS.
- [ ] Implementar e verificar uma aplicação que consome a API CEN/XFS.
- [ ] Implementar e verificar uma aplicação que consome a API J/XFS.
- [ ] Integrar com um equipamento quando o ambiente estiver disponível.

## Registro de estudo

```text
Data e assunto:
Conceito ou contrato estudado:
Referência e versão:
Exercício realizado:
Resultado esperado e observado:
Como explico o comportamento:
Dúvida e próximo passo:
```
