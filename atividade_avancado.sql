USE PlataformaCursos;
GO

-- 1. Transação com COMMIT (Alterar valor e salvar)
BEGIN TRANSACTION;
    UPDATE Cursos SET Valor = 400.00 WHERE NomeCurso = 'SQL Basico';
COMMIT;
-- Verificando
SELECT NomeCurso, Valor FROM Cursos WHERE NomeCurso = 'SQL Basico';
GO

-- 2. Transação com ROLLBACK (Alterar valor e desfazer)
BEGIN TRANSACTION;
    UPDATE Cursos SET Valor = 600.00 WHERE NomeCurso = 'Python Inicial';
ROLLBACK;
-- Verificando (deve voltar a ser 500.00)
SELECT NomeCurso, Valor FROM Cursos WHERE NomeCurso = 'Python Inicial';
GO

-- 3. Inserir matrícula e salvar (COMMIT)
BEGIN TRANSACTION;
    INSERT INTO Matriculas (IdMatricula, IdAluno, IdCurso, DataMatricula, ValorPago)
    VALUES (9, 6, 1, '20261020', 400.00);
COMMIT;
-- Verificando
SELECT * FROM Matriculas WHERE IdMatricula = 9;
GO

-- 4. Inserir matrícula e desfazer (ROLLBACK)
BEGIN TRANSACTION;
    INSERT INTO Matriculas (IdMatricula, IdAluno, IdCurso, DataMatricula, ValorPago)
    VALUES (10, 1, 5, '20261020', 200.00);
ROLLBACK;
-- Verificando (não deve retornar nada)
SELECT * FROM Matriculas WHERE IdMatricula = 10;
GO

/*Exercicio 1 ao 3 views*/

-- 1. View de Alunos
CREATE VIEW vw_Alunos AS
SELECT IdAluno, Nome, Cidade FROM Alunos;
GO
SELECT * FROM vw_Alunos;
GO

-- 2. View de Matrículas com JOIN
CREATE VIEW vw_MatriculasAlunos AS
SELECT M.IdMatricula, A.Nome AS NomeAluno, C.NomeCurso, M.DataMatricula, M.ValorPago
FROM Matriculas M
INNER JOIN Alunos A ON M.IdAluno = A.IdAluno
INNER JOIN Cursos C ON M.IdCurso = C.IdCurso;
GO
SELECT * FROM vw_MatriculasAlunos;
GO

-- 3. View de Cursos Caros
CREATE VIEW vw_CursosCaros AS
SELECT IdCurso, NomeCurso, Categoria, Valor FROM Cursos WHERE Valor > 500.00;
GO
SELECT * FROM vw_CursosCaros;
GO

/*Stored Procedures*/

-- 1. Procedure Listar Alunos
CREATE PROCEDURE sp_ListarAlunos AS BEGIN SELECT * FROM Alunos; END;
GO
EXEC sp_ListarAlunos;
GO

-- 2. Procedure Matrículas por Aluno
CREATE PROCEDURE sp_MatriculasPorAluno @IdAluno INT AS
BEGIN
    SELECT M.IdMatricula, A.Nome AS NomeAluno, C.NomeCurso, M.DataMatricula, M.ValorPago
    FROM Matriculas M
    INNER JOIN Alunos A ON M.IdAluno = A.IdAluno
    INNER JOIN Cursos C ON M.IdCurso = C.IdCurso
    WHERE M.IdAluno = @IdAluno;
END;
GO
EXEC sp_MatriculasPorAluno @IdAluno = 1; -- Testando com a Ana
GO

-- 3. Procedure Cursos por Valor
CREATE PROCEDURE sp_CursosPorValor @ValorMinimo DECIMAL(10,2) AS
BEGIN
    SELECT IdCurso, NomeCurso, Categoria, Valor FROM Cursos WHERE Valor >= @ValorMinimo;
END;
GO
EXEC sp_CursosPorValor @ValorMinimo = 300.00;
GO

/*Funcoes*/

-- 1. Criar a Função
CREATE FUNCTION fn_AplicarAcrescimo (@ValorOriginal DECIMAL(10,2), @Percentual DECIMAL(5,2))
RETURNS DECIMAL(10,2) AS
BEGIN
    RETURN @ValorOriginal + (@ValorOriginal * (@Percentual / 100.0));
END;
GO

-- 2. Usar a Função na consulta
SELECT NomeCurso, Valor AS ValorOriginal, dbo.fn_AplicarAcrescimo(Valor, 10.00) AS ValorComAcrescimo10
FROM Cursos;
GO

/*Triggers*/

-- 1. Trigger de aviso após inserção em Matriculas
CREATE TRIGGER trg_AvisoInsercaoMatricula ON Matriculas AFTER INSERT AS
BEGIN
    PRINT 'Um novo registro de matrícula foi inserido com sucesso!';
END;
GO
-- Testando a trigger (a mensagem aparece na aba "Messages" ou "Output")
INSERT INTO Matriculas (IdMatricula, IdAluno, IdCurso, DataMatricula, ValorPago)
VALUES (11, 2, 4, '20261020', 900.00);
GO

-- 2. Trigger que impede valores negativos
CREATE TRIGGER trg_ImpedeValorNegativo ON Cursos AFTER INSERT, UPDATE AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Valor < 0)
    BEGIN
        RAISERROR('Erro: O valor do curso nao pode ser negativo.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

