README – Atividade SQL (Views, Tabelas, Trigger, Função e Procedure)

Este documento descreve o passo a passo da construção dos objetos SQL solicitados: VIEW, TABELA, TRIGGER, FUNÇÃO e PROCEDURE, seguindo os itens de A a G.

🅰️ A) Criação da VIEW

Criar uma view com as seguintes informações:

productCode

quantityOrdered (somada)

quantityInStock

estoqueTotal = quantityOrdered + quantityInStock

A view deve agrupar corretamente a quantidade vendida.

🅱️ B) Criar uma tabela baseada na VIEW

Gerar uma nova tabela copiando os resultados da view criada no passo A.
Essa tabela será utilizada para cálculos e auditorias.

🅲 C) Criar tabela de auditoria

Criar uma tabela para monitorar alterações realizadas na tabela criada na letra B.

A tabela deve conter:

id (PK, auto increment)

descricao (texto sobre a alteração)

dataModificacao (timestamp da operação)

🅳 D) Alteração da tabela (letra B)

Alterar a tabela criada no passo B, adicionando:

percentualVendido

observacao

Esses campos serão atualizados pela procedure.

🅴 E) Trigger de auditoria

Criar uma trigger que execute sempre que um registro da tabela da letra B for atualizado.
A trigger deve inserir uma descrição da alteração na tabela de auditoria.

🅵 F) Função de cálculo do percentual vendido

Criar uma função que receba:

totalDeProdutoVendidos

estoqueTotal

e retorne:

percentual = (totalDeProdutoVendidos / estoqueTotal) * 100
🅶 G) Procedure – Processamento e atualização de estoque

A procedure deve seguir o fluxo:

1. Criar a procedure sem parâmetros

Será uma procedure geral responsável por atualizar toda a tabela.

2. Criar um cursor

O cursor irá percorrer toda a tabela da letra B, já com os campos adicionados na letra D.

3. Iniciar a transação

Garantir consistência durante o processamento.

4. Chamar a função do percentual vendido

A função criada na letra F será usada dentro do loop do cursor.

5. Aplicar regras de observação

De acordo com o percentual:

Percentual vendido	Observação
> 70%	REPOSIÇÃO DE ESTOQUE
50%–70%	ESTOQUE EM ATENÇÃO
< 50%	PRODUTO CONTROLADO
6. Atualizar os campos

Atualizar na tabela:

percentualVendido

observacao

7. Finalizar transação

Dar commit se tudo estiver correto.

✔️ Conclusão

Este projeto demonstra domínio das seguintes habilidades:

Criação de views

Manipulação de tabelas

Implementação de triggers de auditoria

Escrever funcões SQL personalizadas

Construir procedures complexas com cursor e transações

Aplicar lógica de negócios dentro do banco de dados

Caso deseje, posso gerar todos os scripts SQL completos e funcionando, seguindo exatamente cada etapa descrita neste README.

Basta pedir: "Gerar scripts SQL".
