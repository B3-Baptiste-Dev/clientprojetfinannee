-- Création de la base de données
CREATE DATABASE IF NOT EXISTS test;
USE test;

-- Création de la table Utilisateur
CREATE TABLE IF NOT EXISTS Utilisateur (
    ID_Utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    Nom_Utilisateur VARCHAR(255) NOT NULL,
    Role_Utilisateur VARCHAR(100) NOT NULL
);

-- Création des autres tables
CREATE TABLE IF NOT EXISTS Compte (
    ID_Compte INT AUTO_INCREMENT PRIMARY KEY,
    Nom_Compte VARCHAR(255) NOT NULL,
    Solde DECIMAL(15, 2) NOT NULL,
    Date_Ouverture DATE NOT NULL,
    ID_Utilisateur INT,
    FOREIGN KEY (ID_Utilisateur) REFERENCES Utilisateur(ID_Utilisateur) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Transaction (
   ID_Transaction INT AUTO_INCREMENT PRIMARY KEY,
   Date_Transaction DATE NOT NULL,
   Montant DECIMAL(15, 2) NOT NULL,
    Type_Transaction VARCHAR(50) NOT NULL,
    ID_Compte INT NOT NULL,
    FOREIGN KEY (ID_Compte) REFERENCES Compte(ID_Compte) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Client (
    ID_Client INT AUTO_INCREMENT PRIMARY KEY,
    Nom_Client VARCHAR(255) NOT NULL,
    Adresse_Client VARCHAR(255),
    Email_Client VARCHAR(255),
    Telephone_Client VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Fournisseur (
    ID_Fournisseur INT AUTO_INCREMENT PRIMARY KEY,
    Nom_Fournisseur VARCHAR(255) NOT NULL,
    Adresse_Fournisseur VARCHAR(255),
    Email_Fournisseur VARCHAR(255),
    Telephone_Fournisseur VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Facture (
    ID_Facture INT AUTO_INCREMENT PRIMARY KEY,
    Date_Facture DATE NOT NULL,
    Montant_Total DECIMAL(15, 2) NOT NULL,
    ID_Client INT,
    ID_Fournisseur INT,
    Statut_Facture VARCHAR(50) NOT NULL,
    FOREIGN KEY (ID_Client) REFERENCES Client(ID_Client),
    FOREIGN KEY (ID_Fournisseur) REFERENCES Fournisseur(ID_Fournisseur)
);

CREATE TABLE IF NOT EXISTS Article (
    ID_Article INT AUTO_INCREMENT PRIMARY KEY,
    Nom_Article VARCHAR(255) NOT NULL,
    Description_Article TEXT,
    Prix_Unitaire DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS LigneFacture (
    ID_LigneFacture INT AUTO_INCREMENT PRIMARY KEY,
    ID_Facture INT NOT NULL,
    ID_Article INT NOT NULL,
    Quantite INT NOT NULL,
    Prix_Total DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (ID_Facture) REFERENCES Facture(ID_Facture),
    FOREIGN KEY (ID_Article) REFERENCES Article(ID_Article)
);

CREATE TABLE IF NOT EXISTS Alerte (
    ID_Alerte INT AUTO_INCREMENT PRIMARY KEY,
    ID_Compte INT NOT NULL,
    Message VARCHAR(255) NOT NULL,
    Date_Alerte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Compte) REFERENCES Compte(ID_Compte) ON DELETE CASCADE
);

-- Utilisateurs
INSERT INTO Utilisateur (Nom_Utilisateur, Role_Utilisateur) VALUES
('Admin', 'Administrateur'),
('User', 'Utilisateur');

-- Comptes associés à l'Utilisateur 1 (Admin) par simplicité d'exemple
INSERT INTO Compte (Nom_Compte, Solde, Date_Ouverture, ID_Utilisateur) VALUES
('Nom du Compte 1', 1000.00, '2023-01-01', 1),
('Nom du Compte 2', 500.00, '2023-01-02', 1),
('Nom du Compte 3', 200.00, '2023-01-03', 1);


-- Transactions associées au Compte 1 (Compte Courant)
INSERT INTO Transaction (Date_Transaction, Montant, Type_Transaction, ID_Compte) VALUES
('2023-02-01', -150.00, 'Débit', 1),
('2023-02-02', 200.00, 'Crédit', 1);
-- Clients
INSERT INTO Client (Nom_Client, Adresse_Client, Email_Client, Telephone_Client) VALUES
('Entreprise X', "123 rue de l'entreprise", 'contact@entreprisex.com', '0123456789');

-- Fournisseurs
INSERT INTO Fournisseur (Nom_Fournisseur, Adresse_Fournisseur, Email_Fournisseur, Telephone_Fournisseur) VALUES
('Fournisseur Y', '456 avenue du fournisseur', 'info@fournisseury.com', '9876543210');

-- Factures
INSERT INTO Facture (Date_Facture, Montant_Total, ID_Client, Statut_Facture) VALUES
('2023-03-01', 1500.00, 1, 'Payée');

-- Articles
INSERT INTO Article (Nom_Article, Description_Article, Prix_Unitaire) VALUES
('Article Z', 'Un article très demandé', 50.00);

-- Lignes de Facture
INSERT INTO LigneFacture (ID_Facture, ID_Article, Quantite, Prix_Total) VALUES
(1, 1, 30, 1500.00);

INSERT INTO Alerte (ID_Compte, Message) VALUES
(1, 'Découvert provoqué par une nouvelle transaction'),
(2, 'Découvert provoqué par une nouvelle transaction'),
(3, 'Découvert provoqué par une nouvelle transaction');

-- Création de l'utilisateur de la base de données
DROP USER IF EXISTS 'comptaUser'@'localhost';
CREATE USER 'comptaUser'@'localhost' IDENTIFIED BY 'motDePasseFort';
GRANT ALL PRIVILEGES ON test.* TO 'comptaUser'@'localhost';
FLUSH PRIVILEGES;

-- Ajout des triggers selon tes besoins
DELIMITER $$

-- Trigger pour gérer le découvert sur un compte bancaire
CREATE TRIGGER alerte_decouvert
    AFTER INSERT ON Transaction
    FOR EACH ROW
BEGIN
    DECLARE soldeActuel DECIMAL(15,2);
    DECLARE soldeApresTransaction DECIMAL(15,2);

    -- Récupère le solde actuel du compte concerné
    SELECT Solde INTO soldeActuel FROM Compte WHERE ID_Compte = NEW.ID_Compte;

    -- Calcule le solde après la transaction
    SET soldeApresTransaction = soldeActuel + NEW.Montant;

    -- Vérifie si le solde après transaction est négatif
    IF soldeApresTransaction < 0 THEN
        -- Insère une alerte de découvert
        INSERT INTO Alerte (ID_Compte, Message)
        VALUES (NEW.ID_Compte, 'Découvert provoqué par une nouvelle transaction');
END IF;
END$$

DELIMITER ;