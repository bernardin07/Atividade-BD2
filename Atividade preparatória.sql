use classicmodels;

/* A) criar uma view considerando as informações o produto (productcode), quantidade de
Produto (quantityOrdered), Estoque Atual (quantityInStock), EstoqueTotal
(quantityOrdered + quantityInStock). DICA: quantityOrdered tem que ser somado. */

CREATE OR REPLACE VIEW PRODUCT_ESTOQUE AS
SELECT
	PRODUCTCODE AS PRODUTO,
    SUM(QUANTITYORDERED) AS QTDE_PEDIDO,
    quantityInStock,
    (quantityOrdered + quantityInStock) AS ESTOQUETOTAL
FROM
	ORDERDETAILS
		INNER JOIN PRODUCTS USING(PRODUCTCODE)
GROUP BY
	PRODUCTCODE,quantityInStock,ESTOQUETOTAL;
    
/* B) Crie uma tabela baseada na consulta da view da questão anterior. */

DROP TABLE IF EXISTS ESTOQUE_PRODUTO;
CREATE TABLE IF NOT EXISTS ESTOQUE_PRODUTO AS
SELECT
	PRODUTOS,
    QTDE_PEDIDO,
    quantityInStock,
    ESTOQUETOTAL
FROM
	PRODUCT_ESTOQUE;

/* C) Criar uma tabela de auditoria que irá monitorar as alterações que acontecerem na
tabela. Ela deverá ter os campos de Id, Descricao e dataModificacao. */

CREATE TABLE IF NOT EXISTS AUDITORIA(
	ID INT AUTO_INCREMENT PRIMARY KEY,
    DESCRICAO TEXT,
    DATA_MODIFICACAO TIMESTAMP
)ENGINE=INNODB;

/* D) Faça uma alteração na tabela cridada na letra B, incluindo os campos de
percentualVendido e observacao. */

ALTER TABLE ESTOQUE_PRODUTO 
ADD COLUMN percentualVendido DECIMAL(5,2),
ADD COLUMN observacao TEXT;

/* E) Crie uma trigger que deverá ser disparada para alterações realizada na tabela da
lebra B. A trigger deverá inserir as informações na tabela de auditoria. */

CREATE TRIGGER TRG_AUDITORIA_ESTOQUE
AFTER UPDATE ON ESTOQUE_PRODUTO
FOR EACH ROW
INSERT INTO AUDITORIA (DESCRICAO)
VALUES (CONCAT('registro alterado para o produto: ', NEW.PRODUTO));

/* F) Crie a um função para o percentual vendido, que deverá receber
totaldeProdutoVendidos e Estoque Total. */

DELIMITER %
DROP FUNCTION IF EXISTS CALCULAR_PERCENTUAL%
CREATE FUNCTION CALCULAR_PERCENTUAL(totalDeProdutoVendidos INT, EstoqueTotal INT) RETURNS DECIMAL(5,2) DETERMINISTIC
BEGIN
	DECLARE VAR_RETORNAR DECIMAL(5,2);
    SET VAR_RETORNAR = ROUND((totalDeProdutoVendidos / EstoqueTotal)*100,2);
    RETURN VAR_RETORNAR;
END%
DELIMITER ;

/* G) Criar um procedure de acordo com o passo a passo abaixo:
1 - Criar procedure sem parâmetros de entrada
2 - Fazer um cursor com base na consulta da tabela de letra B (ja com os campos
alterados)
3 - Começar a transação
4 - Fazer a chamada da procedure para o calculo do percentual.
5 - Se o percentual for maior que 70% deverá escrever no campo observação:
REPOSIÇÃO DE ESTOQUE. Entre 50 e 70% escrever no campo observação:
ESTOQUE EM ATENÇÃO. Se menor 50% escrever: PRODUTO CONTROLADO
6 - Atualizar a tabela nos campos percentualVendido e observação
7 - Aceitar as alterações realizadas na transação. */

DELIMITER %
DROP PROCEDURE IF EXISTS ATUALIZAR_ESTOQUE%
CREATE PROCEDURE ATUALIZAR_ESTOQUE()
BEGIN
	DECLARE VAR_DONE BOOL DEFAULT FALSE;
    DECLARE VAR_PRODUCTCODE VARCHAR(20);
    DECLARE VAR_QTDE_PEDIDO INT;
    DECLARE VAR_ESTOQUETOTAL INT;
    DECLARE VAR_PERCENTUAL DECIMAL(5,2);
    DECLARE VAR_TEXTO TEXT;
    
    DECLARE CURSOR_ESTOQUE CURSOR FOR
	SELECT
		PRODUTO,
        QTDE_PEDIDO,
        ESTOQUETOTAL
	FROM 
		PRODUCT_ESTOQUE;
	
    DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET VAR_DONE = TRUE;
	
    START TRANSACTION;
    OPEN CURSOR_ESTOQUE;
    
    LISTA: LOOP
		FETCH CURSOR_ESTOQUE INTO VAR_PRODUCTCODE,VAR_QTDE_PEDIDO,VAR_ESTOQUETOTAL;
        
        IF (VAR_DONE = TRUE) THEN
			LEAVE LISTA;
		END IF;
        
        IF (VAR_QTDE_PEDIDO > 0 AND VAR_ESTOQUETOTAL > 0) THEN
			SET VAR_PERCENTUAL = CALCULAR_PERCENTUAL(VAR_QTDE_PEDIDO,VAR_ESTOQUETOTAL);
            
            SELECT
				CASE
					WHEN VAR_PERCENTUAL > 70 THEN 'REPOSIÇÃO DE ESTOQUE'
                    WHEN VAR_PERCENTUAL > 50 THEN 'ESTOQUE EM ATENÇÃO'
                    ELSE 'PRODUTO CONTROLADO'
				END
			INTO VAR_TEXTO;
            
			UPDATE ESTOQUE_PRODUTO
            SET 
				percentualVendido = VAR_PERCENTUAL,
				observacao = VAR_TEXTO
            WHERE PRODUCTCODE = VAR_PRODUCTCODE;
        ELSE
			SELECT 'INFORMAÇÃO IGUAL OU MENOR QUE 0' AS RESULTADO;
			ROLLBACK;
		END IF;
    END LOOP;
    
    CLOSE CURSOR_ESTOQUE;
    COMMIT;
END%
DELIMITER ;

CALL ATUALIZAR_ESTOQUE();
SELECT * FROM ESTOQUE_PRODUTO;
SELECT * FROM AUDITORIA;
