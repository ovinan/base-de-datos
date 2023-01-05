/* EJEMPLO SENCILLO CREACION DE OBJETOS CON METODOS Y EJECUCION DE LOS METODOS */
/* Creamos el objeto TIPO_CUBO, con 3 atributos y 2 metodos */
CREATE OR REPLACE TYPE Tipo_Cubo AS OBJECT (
    largo INTEGER,
    ancho INTEGER,
    alto INTEGER,
    MEMBER FUNCTION superficie RETURN INTEGER,
    MEMBER FUNCTION volumen RETURN INTEGER
);
/
/* Programamos el codigo de los metodos */
CREATE OR REPLACE TYPE BODY Tipo_Cubo AS
    MEMBER FUNCTION volumen RETURN INTEGER IS
    BEGIN
        RETURN largo * ancho * alto;
    END;
    MEMBER FUNCTION superficie RETURN INTEGER IS
    BEGIN
        RETURN 2 * (largo * ancho + largo * alto + ancho * alto);
    END;
END;
/
/* Creamos la tabla de objetos  */
CREATE TABLE Cubos of Tipo_Cubo;
/
INSERT INTO Cubos VALUES(Tipo_Cubo (10, 10, 10));
/
INSERT INTO Cubos VALUES(Tipo_Cubo (3, 4, 5));
/
/* Consultamos la tabla de objetos */
SELECT * FROM Cubos;
/
/* Ejecutamos los metodos de la tabla de objetos */
SELECT c.largo, c.ancho,c.alto,c.volumen(), c.superficie () 
FROM Cubos c
WHERE c.largo = 10; 


