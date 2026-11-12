# Exercícios iniciais — lógica em C

## Objetivo desta etapa

Aprender variáveis, operações, decisões, repetições e funções em C. Essa base será usada depois no estudo das APIs CEN/XFS. Ponteiros, estruturas e integração com dispositivos ficam para as próximas etapas.

Faça os exercícios na ordem, um por vez. Este material contém enunciados e resultados esperados; escreva suas próprias soluções.

## Como organizar e executar

Crie seus arquivos em `exercises/c/basics/`, usando os nomes em inglês indicados abaixo. Cada arquivo terá seu próprio `main` e deverá ser compilado separadamente.

Estrutura inicial de um programa C:

```c
#include <stdio.h>

int main(void) {
    /* Seu exercício aqui. */
    return 0;
}
```

O arquivo atual `src/main.cpp` usa C++. Nos exercícios desta etapa, use a extensão `.c`, `printf` para saída e `scanf` para leitura.

Se você usa GCC, um exemplo de compilação no PowerShell, a partir da raiz do projeto, é:

```powershell
gcc -std=c17 -Wall -Wextra -Wpedantic exercises/c/basics/01_hello.c -o exercises/c/basics/01_hello.exe
.\exercises\c\basics\01_hello.exe
```

Esse comando depende de GCC instalado e disponível no terminal. Outros compiladores podem exigir comandos diferentes. Não compile todos os arquivos juntos, pois cada exercício é um programa independente.

Para ler um inteiro, você pode usar este pequeno exemplo:

```c
int value = 0;

printf("Digite um inteiro: ");
if (scanf("%d", &value) != 1) {
    printf("Entrada invalida.\n");
    return 1;
}
```

`%d` representa um inteiro. Em `scanf`, `&value` informa onde guardar o valor lido; ponteiros serão aprofundados depois. O retorno `1` indica que uma conversão foi realizada. Nos exercícios com várias leituras, confira cada uma delas. Ao encontrar texto onde era esperado um número, apresente uma mensagem e encerre o programa; repetir a leitura após essa falha fica para outra etapa.

## Método para cada exercício

1. Escreva, em português, os passos para resolver o problema.
2. Escolha pelo menos três entradas e calcule os resultados à mão.
3. Implemente em C e compile observando os avisos.
4. Execute e compare com suas previsões.
5. Explique o papel de cada variável e condição.

Use os limites pedidos nos enunciados para manter as contas pequenas. Não precisa tratar números de tamanho arbitrário nesta etapa.

## 1. Primeira saída

**Arquivo:** `01_hello.c`

Escreva um programa que apresente exatamente:

```text
Meu primeiro exercicio em C.
Estou estudando logica para trabalhar com APIs.
```

**Estudar:** `#include`, `main`, `printf`, `\n`, ponto e vírgula e `return`.

**Concluído quando:** conseguir explicar como imprimir duas linhas e qual é a função de `\n`.

## 2. Variáveis e cálculos

**Arquivo:** `02_arithmetic.c`

Declare dois inteiros, `a = 10` e `b = 3`. Mostre soma, subtração, multiplicação, divisão inteira e resto da divisão. Depois, mostre também a divisão com parte decimal, convertendo um dos operandos para `double`.

Resultados esperados, na mesma ordem: `13`, `7`, `30`, `3`, `1` e aproximadamente `3.33`.

**Estudar:** `int`, `double`, `+`, `-`, `*`, `/`, `%`, conversão de tipo e `%.2f`.

**Pergunta:** por que guardar `a / b` em um `double`, sem converter nenhum operando, não recupera a parte decimal?

## 3. Entrada de dados

**Arquivo:** `03_sum_inputs.c`

Leia dois inteiros entre -100 e 100 e mostre sua soma. Se algum valor estiver fora desse intervalo, informe o erro e encerre.

| Entradas | Resultado esperado |
| --- | --- |
| 4 e 6 | 10 |
| -3 e 8 | 5 |
| 0 e 0 | 0 |
| 101 e 2 | Mensagem de valor fora do intervalo |
| Texto no lugar de um inteiro | Mensagem de entrada inválida |

**Estudar:** leitura, validação e diferença entre atribuição `=` e comparação `==`.

## 4. Decisões: sinal e paridade

**Arquivo:** `04_number_classification.c`

Leia um inteiro entre -100 e 100. Informe se ele é positivo, negativo ou zero. Depois, informe se é par ou ímpar.

| Entrada | Classificação |
| --- | --- |
| 8 | Positivo e par |
| -3 | Negativo e ímpar |
| 0 | Zero e par |

**Estudar:** `if`, `else if`, `else` e resto da divisão.

**Pergunta:** por que verificar `number % 2 != 0` funciona para identificar ímpares negativos também?

## 5. Decisões: maior valor

**Arquivo:** `05_largest_number.c`

Leia três inteiros entre -100 e 100 e mostre o maior valor. Empates são permitidos: basta imprimir o valor uma vez.

| Entradas | Resultado esperado |
| --- | --- |
| 2, 9, 4 | 9 |
| -8, -2, -5 | -2 |
| 7, 7, 3 | 7 |
| 0, 0, 0 | 0 |

**Dica:** comece considerando o primeiro número como o maior e compare os demais com ele.

**Pergunta:** o que pode dar errado se a variável que guarda o maior começar em zero?

## 6. Repetição: contagem

**Arquivo:** `06_counting.c`

Leia um limite entre 1 e 20. Imprima os números de 1 até esse limite, um por linha. Em seguida, imprima do limite até 1. Rejeite valores fora do intervalo.

Para o limite `3`, a saída numérica deve ser:

```text
1
2
3
3
2
1
```

**Estudar:** `for`, inicialização, condição de parada, incremento e decremento.

**Pergunta:** qual é a diferença entre usar `< limit` e `<= limit` na contagem crescente?

## 7. Soma acumulada — ligação com o código atual

**Arquivo:** `07_running_total.c`

Reescreva em C a lógica de `src/main.cpp`. Primeiro, use o limite fixo `3` e imprima o total após cada soma. Depois, leia um limite entre 0 e 100 e imprima também o resultado final, identificado por uma mensagem.

| Limite | Totais durante o laço | Resultado final |
| --- | --- | --- |
| 0 | Nenhum | 0 |
| 1 | 1 | 1 |
| 3 | 1, 3, 6 | 6 |
| 5 | 1, 3, 6, 10, 15 | 15 |

**Estudar:** acumulador, `+=`, escopo e diferença entre imprimir dentro e depois do laço.

**Antes de executar:** monte uma tabela com contador, total antes da soma e total depois da soma.

**Experimento:** declare o acumulador dentro do laço, observe a mudança e explique por que ele perde o total das repetições anteriores. Depois, restaure a solução.

## 8. Repetição com sentinela

**Arquivo:** `08_sum_until_zero.c`

Leia números entre -100 e 100 até receber zero. Some os valores e conte quantos números foram informados, excluindo o zero final. Aceite no máximo 100 valores diferentes de zero; ao atingir esse limite, encerre a coleta e mostre o resultado. Um valor fora do intervalo deve gerar erro e encerrar o programa.

| Sequência de entrada | Quantidade | Soma |
| --- | --- | --- |
| 4, -1, 7, 0 | 3 | 10 |
| 0 | 0 | 0 |
| -2, -3, 0 | 2 | -5 |

**Estudar:** `while`, sentinela, contador e acumulador.

**Pergunta:** como garantir que o zero usado para encerrar não entre na contagem?

## 9. Funções

**Arquivo:** `09_functions.c`

Extraia a lógica da soma de 1 até um limite para uma função:

```c
int sumUpTo(int limit);
```

O contrato da função é receber um limite entre 0 e 100 e retornar a soma. A validação de entrada pertence ao `main`. A função deve apenas calcular e retornar, sem ler nem imprimir.

Verifique os seguintes resultados:

| Chamada | Retorno |
| --- | --- |
| `sumUpTo(0)` | 0 |
| `sumUpTo(1)` | 1 |
| `sumUpTo(3)` | 6 |
| `sumUpTo(100)` | 5050 |

**Estudar:** declaração, definição, parâmetro, argumento, retorno e variável local.

**Pergunta:** por que a função pode ser reutilizada com mais facilidade quando a leitura e a impressão ficam fora dela?

## 10. Desafio final: menu de operações

**Arquivo:** `10_menu.c`

Crie um programa que apresente este menu repetidamente:

```text
1 - Somar de 1 ate um limite
2 - Verificar se um numero e par
3 - Mostrar o maior de dois numeros
0 - Sair
```

Requisitos:

- Usar `switch` para escolher a operação e um laço para repetir o menu.
- Criar funções `sumUpTo`, `isEven` e `maxOfTwo`.
- Usar limites de 0 a 100 para a soma e de -100 a 100 nas outras operações.
- Fazer `isEven` retornar 1 para par e 0 para ímpar.
- Tratar uma opção numérica desconhecida com uma mensagem e voltar ao menu.
- Tratar um operando numérico fora do intervalo com uma mensagem e voltar ao menu.
- Encerrar com uma mensagem se uma leitura falhar por receber texto.
- Encerrar normalmente quando a opção for zero.

**Verificação manual:** execute duas operações seguidas, tente a opção `9`, teste um operando fora do intervalo e saia com `0`. Em outra execução, informe texto para verificar a falha de leitura.

**Concluído quando:** conseguir explicar o fluxo desde a leitura da opção até o retorno ao menu, incluindo os caminhos de erro.

## Checklist antes da próxima etapa

- [ ] Consegui compilar e executar cada programa separadamente.
- [ ] Entendo os avisos emitidos pelo compilador nos meus exercícios.
- [ ] Sei diferenciar atribuição, comparação e operação aritmética.
- [ ] Consigo escolher entre `if`, `switch`, `for` e `while`.
- [ ] Sei explicar contador, acumulador, escopo e condição de parada.
- [ ] Consigo escrever e chamar funções com parâmetros e retorno.
- [ ] Verifiquei casos com zero, negativos, limites e entradas inválidas.
- [ ] Consigo resolver novamente um exercício sem consultar a solução.

A próxima etapa será trabalhar com arrays, strings, ponteiros e estruturas em C, preparando a leitura dos tipos e parâmetros encontrados nas APIs. Primeiro, conclua e revise estes exercícios.

## Registro curto por exercício

```text
Arquivo:
Passos da solução em português:
Entradas e resultados previstos:
Resultado observado:
Erro que encontrei e como corrigi:
O que consigo explicar:
Dúvida que ficou:
```
