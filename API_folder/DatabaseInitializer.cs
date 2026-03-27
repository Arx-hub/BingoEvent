using Microsoft.Data.Sqlite;
using System;

namespace BingoEvent.API;

public static class DatabaseInitializer
{
    /// <summary>
    /// Creates all database tables if they don't already exist using raw SQLite commands.
    /// This avoids EF Core migration conflicts with existing databases.
    /// </summary>
    public static void Initialize(string connectionString)
    {
        using var connection = new SqliteConnection(connectionString);
        connection.Open();

        // BingoBoards table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS BingoBoards (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT NOT NULL DEFAULT '',
                    Boxes TEXT NOT NULL DEFAULT '[]',
                    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
                    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
                    IsActive INTEGER NOT NULL DEFAULT 1
                );";
            cmd.ExecuteNonQuery();
        }

        // HelloWorldEntries table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS HelloWorldEntries (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Message TEXT,
                    CreatedAt TEXT NOT NULL DEFAULT (datetime('now'))
                );";
            cmd.ExecuteNonQuery();
        }

        // WelcomePages table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS WelcomePages (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT,
                    Title TEXT NOT NULL DEFAULT '',
                    Subtitle TEXT NOT NULL DEFAULT ''
                );";
            cmd.ExecuteNonQuery();
        }

        // Games table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS Games (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT
                );";
            cmd.ExecuteNonQuery();
        }

        // Events table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS Events (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT NOT NULL DEFAULT '',
                    Creator TEXT NOT NULL DEFAULT '',
                    WelcomePageId INTEGER NOT NULL,
                    BingoBoardId INTEGER NOT NULL,
                    GameNames TEXT NOT NULL DEFAULT '[]',
                    QuestionPackageId INTEGER,
                    FOREIGN KEY(WelcomePageId) REFERENCES WelcomePages(Id),
                    FOREIGN KEY(BingoBoardId) REFERENCES BingoBoards(Id),
                    FOREIGN KEY(QuestionPackageId) REFERENCES QuestionPackages(Id)
                );";
            cmd.ExecuteNonQuery();
        }

        // QuestionPackages table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS QuestionPackages (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT NOT NULL DEFAULT '',
                    IsDefault INTEGER NOT NULL DEFAULT 0,
                    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
                    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now'))
                );";
            cmd.ExecuteNonQuery();
        }

        // Questions table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS Questions (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    QuestionPackageId INTEGER NOT NULL,
                    QuestionText TEXT NOT NULL DEFAULT '',
                    Answer1 TEXT NOT NULL DEFAULT '',
                    Answer2 TEXT NOT NULL DEFAULT '',
                    Answer3 TEXT NOT NULL DEFAULT '',
                    CorrectAnswer INTEGER NOT NULL DEFAULT 1,
                    FOREIGN KEY(QuestionPackageId) REFERENCES QuestionPackages(Id) ON DELETE CASCADE
                );";
            cmd.ExecuteNonQuery();
        }

        // Add missing columns to Events if they don't exist (for existing DBs)
        AddColumnIfNotExists(connection, "Events", "GameNames", "TEXT NOT NULL DEFAULT '[]'");

        // Add missing columns to BingoBoards if they don't exist (for existing DBs)
        // Note: ALTER TABLE ADD COLUMN only allows constant defaults in SQLite
        AddColumnIfNotExists(connection, "BingoBoards", "Boxes", "TEXT NOT NULL DEFAULT '[]'");
        AddColumnIfNotExists(connection, "BingoBoards", "CreatedAt", "TEXT NOT NULL DEFAULT '2026-01-01 00:00:00'");
        AddColumnIfNotExists(connection, "BingoBoards", "UpdatedAt", "TEXT NOT NULL DEFAULT '2026-01-01 00:00:00'");
        AddColumnIfNotExists(connection, "BingoBoards", "IsActive", "INTEGER NOT NULL DEFAULT 1");

        // Add missing columns to WelcomePages if they don't exist (for existing DBs)
        AddColumnIfNotExists(connection, "WelcomePages", "Title", "TEXT NOT NULL DEFAULT ''");
        AddColumnIfNotExists(connection, "WelcomePages", "Subtitle", "TEXT NOT NULL DEFAULT ''");

        // Add missing columns to Events if they don't exist (for existing DBs)
        AddColumnIfNotExists(connection, "Events", "QuestionPackageId", "INTEGER");

        // Seed default WelcomePage if empty
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = "INSERT OR IGNORE INTO WelcomePages (Id, Name, Title, Subtitle) VALUES (1, 'Default Welcome Page', 'Welcome!', '');";
            cmd.ExecuteNonQuery();
        }

        // Seed default Game if empty
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = "INSERT OR IGNORE INTO Games (Id, Name) VALUES (1, 'Default Game');";
            cmd.ExecuteNonQuery();
        }

        // Seed default Question Packages
        SeedDefaultQuestionPackages(connection);

        Console.WriteLine("Database initialized successfully.");
    }

    private static void SeedDefaultQuestionPackages(SqliteConnection connection)
    {
        // Check if default packages already exist
        using (var checkCmd = connection.CreateCommand())
        {
            checkCmd.CommandText = "SELECT COUNT(*) FROM QuestionPackages WHERE IsDefault = 1;";
            var count = Convert.ToInt64(checkCmd.ExecuteScalar());
            if (count > 0) return; // Already seeded
        }

        var packages = new[]
        {
            new {
                Name = "ICT - Tieto- ja viestintätekniikka",
                Questions = new[] {
                    new { Q = "Mikä on HTML:n lyhenne?", A1 = "HyperText Markup Language", A2 = "High Tech Modern Language", A3 = "Home Tool Markup Language", C = 1 },
                    new { Q = "Mikä protokolla suojaa verkkoliikennettä?", A1 = "FTP", A2 = "HTTPS", A3 = "SMTP", C = 2 },
                    new { Q = "Mikä on tietokoneen keskusmuistin (RAM) tehtävä?", A1 = "Tallentaa tiedostot pysyvästi", A2 = "Säilyttää väliaikaisesti käytössä olevaa dataa", A3 = "Ohjata näytön toimintaa", C = 2 },
                    new { Q = "Mikä seuraavista on käyttöjärjestelmä?", A1 = "Python", A2 = "Linux", A3 = "HTML", C = 2 },
                    new { Q = "Mikä on IP-osoitteen tarkoitus?", A1 = "Tunnistaa laite verkossa", A2 = "Salata sähköpostit", A3 = "Nopeuttaa internetyhteyttä", C = 1 },
                    new { Q = "Mitä CSS tekee verkkosivulla?", A1 = "Käsittelee tietokantakyselyjä", A2 = "Määrittää sivun ulkoasun ja tyylin", A3 = "Hallinnoi palvelimen toimintaa", C = 2 },
                    new { Q = "Mikä on SQL?", A1 = "Ohjelmointikieli mobiilisovelluksille", A2 = "Kyselykieli tietokantojen hallintaan", A3 = "Verkkoprotokolla", C = 2 },
                    new { Q = "Mikä yksikkö mittaa prosessorin nopeutta?", A1 = "Megapikseli", A2 = "Gigahertsi (GHz)", A3 = "Teratavu", C = 2 },
                    new { Q = "Mikä on pilvipalvelu?", A1 = "Fyysinen palvelinkeskus toimistossa", A2 = "Internetin kautta tarjottava tietotekniikkapalvelu", A3 = "Langaton lähiverkko", C = 2 },
                    new { Q = "Mitä tarkoittaa avoin lähdekoodi (open source)?", A1 = "Ohjelmiston koodi on vapaasti saatavilla ja muokattavissa", A2 = "Ohjelmisto on ilmainen mutta koodia ei voi nähdä", A3 = "Ohjelmisto toimii vain Linuxissa", C = 1 },
                }
            },
            new {
                Name = "Sosiaali- ja terveysalan perustutkinto",
                Questions = new[] {
                    new { Q = "Mikä on verenpaineen normaali yläraja aikuisella?", A1 = "140/90 mmHg", A2 = "160/100 mmHg", A3 = "120/60 mmHg", C = 1 },
                    new { Q = "Mikä laki säätelee potilaan oikeuksia Suomessa?", A1 = "Laki potilaan asemasta ja oikeuksista", A2 = "Työturvallisuuslaki", A3 = "Kuluttajansuojalaki", C = 1 },
                    new { Q = "Mitä tarkoittaa aseptiikka?", A1 = "Lääkkeiden annostelu", A2 = "Toimintatapa, jolla estetään mikrobien pääsy kudoksiin", A3 = "Potilaan ravitsemuksen suunnittelu", C = 2 },
                    new { Q = "Mikä on lähihoitajan tärkein työväline?", A1 = "Tietokone", A2 = "Vuorovaikutustaidot", A3 = "Stetoskooppi", C = 2 },
                    new { Q = "Mikä on diabeteksen yleisin muoto?", A1 = "Tyypin 1 diabetes", A2 = "Tyypin 2 diabetes", A3 = "Raskausdiabetes", C = 2 },
                    new { Q = "Mitä tarkoittaa ergonomia hoitotyössä?", A1 = "Oikeat työskentelyasennot ja -tavat", A2 = "Potilaan lääkehoito", A3 = "Työajan seuranta", C = 1 },
                    new { Q = "Mikä on ensiapu tajuttomalle henkilölle?", A1 = "Anna heti vettä juotavaksi", A2 = "Käännä kylkiasentoon ja soita 112", A3 = "Nosta jalat ylös ja odota", C = 2 },
                    new { Q = "Mikä on salassapitovelvollisuuden tarkoitus?", A1 = "Estää työntekijöiden vuorovaikutus", A2 = "Suojata asiakkaan yksityisyyttä ja henkilötietoja", A3 = "Vähentää paperityötä", C = 2 },
                    new { Q = "Kuinka monta kertaa minuutissa aikuisen sydän lyö levossa?", A1 = "40-50 kertaa", A2 = "60-80 kertaa", A3 = "100-120 kertaa", C = 2 },
                    new { Q = "Mikä vitamiini muodostuu iholla auringonvalon vaikutuksesta?", A1 = "C-vitamiini", A2 = "D-vitamiini", A3 = "B12-vitamiini", C = 2 },
                }
            },
            new {
                Name = "Ravintola-alan perustutkinto",
                Questions = new[] {
                    new { Q = "Mikä on omavalvonnan tarkoitus ravintolassa?", A1 = "Seurata työntekijöiden työaikoja", A2 = "Varmistaa elintarvikkeiden turvallisuus ja hygienia", A3 = "Laskea päivän myynti", C = 2 },
                    new { Q = "Mikä on oikea jääkaapin lämpötila elintarvikkeiden säilytykseen?", A1 = "0-5 °C", A2 = "8-12 °C", A3 = "-2 - 0 °C", C = 1 },
                    new { Q = "Mitä FIFO-periaate tarkoittaa varastonhallinnassa?", A1 = "Viimeinen sisään, ensimmäinen ulos", A2 = "Ensimmäinen sisään, ensimmäinen ulos", A3 = "Kalleimmat tuotteet käytetään ensin", C = 2 },
                    new { Q = "Mikä on gluteeni?", A1 = "Maidon sokeri", A2 = "Viljan proteiini, joka aiheuttaa keliakiaa", A3 = "Lisäaine värjäykseen", C = 2 },
                    new { Q = "Missä lämpötilassa ruokaa tulee kuumentaa uudelleen?", A1 = "Vähintään 50 °C", A2 = "Vähintään 70 °C", A3 = "Vähintään 90 °C", C = 2 },
                    new { Q = "Mikä on mise en place?", A1 = "Jälkiruokalaji Ranskasta", A2 = "Esivalmistelu ja raaka-aineiden valmiiksi asettelu", A3 = "Ruokalistan suunnittelu", C = 2 },
                    new { Q = "Mitä allergeeni tarkoittaa?", A1 = "Ruoan maku", A2 = "Aine, joka voi aiheuttaa allergisen reaktion", A3 = "Ravintoaineiden mittayksikkö", C = 2 },
                    new { Q = "Mikä on anniskelupassin tarkoitus?", A1 = "Todistaa kokkitaidot", A2 = "Osoittaa alkoholilainsäädännön tuntemus", A3 = "Antaa oikeus omistaa ravintola", C = 2 },
                    new { Q = "Mikä bakteerien kasvun kannalta vaarallinen lämpötila-alue on?", A1 = "6-60 °C", A2 = "0-10 °C", A3 = "70-100 °C", C = 1 },
                    new { Q = "Mikä on laktoosi?", A1 = "Maidon luontainen sokeri", A2 = "Viljan proteiini", A3 = "Kananmunan allergeeni", C = 1 },
                }
            },
            new {
                Name = "Liiketoiminnan perustutkinto",
                Questions = new[] {
                    new { Q = "Mikä on liikevaihto?", A1 = "Yrityksen voitto verojen jälkeen", A2 = "Yrityksen myyntituottojen yhteismäärä", A3 = "Yrityksen velkojen summa", C = 2 },
                    new { Q = "Mitä tarkoittaa ALV?", A1 = "Ansiotulolisävero", A2 = "Arvonlisävero", A3 = "Aloittavan liiketoiminnan vero", C = 2 },
                    new { Q = "Mikä on markkinoinnin 4P-malli?", A1 = "Product, Price, Place, Promotion", A2 = "Plan, Profit, People, Process", A3 = "Price, Pension, Product, Platform", C = 1 },
                    new { Q = "Mikä on budjetti?", A1 = "Kirjanpidon tililuettelo", A2 = "Talousarvio tulevalle kaudelle", A3 = "Verottajan päätös", C = 2 },
                    new { Q = "Mikä on asiakassegmentointi?", A1 = "Kilpailijoiden tutkiminen", A2 = "Asiakkaiden jakaminen ryhmiin yhteisten piirteiden perusteella", A3 = "Uuden tuotteen lanseeraus", C = 2 },
                    new { Q = "Mitä tarkoittaa kate?", A1 = "Tuotteen myyntihinnan ja ostohinnan erotus", A2 = "Yrityksen kaikki kulut yhteensä", A3 = "Vuokratuotto kiinteistöstä", C = 1 },
                    new { Q = "Mikä on yrityksen tase?", A1 = "Luettelo yrityksen työntekijöistä", A2 = "Taloudellinen raportti varoista ja veloista", A3 = "Markkinointisuunnitelma", C = 2 },
                    new { Q = "Mikä on logistiikan päätehtävä?", A1 = "Tuotesuunnittelu", A2 = "Tavaran ja tiedon kuljetus oikeaan paikkaan oikeaan aikaan", A3 = "Asiakkaiden rekisteröinti", C = 2 },
                    new { Q = "Mikä on franchising?", A1 = "Yrityksen jakaminen osiin", A2 = "Liiketoimintamallin käyttöoikeuden myöntäminen toiselle yrittäjälle", A3 = "Verkkokaupan perustaminen", C = 2 },
                    new { Q = "Mitä tarkoittaa brändi?", A1 = "Yrityksen tilinumero", A2 = "Tuotteen tai yrityksen tunnettu nimi ja mielikuva", A3 = "Varastointitapa", C = 2 },
                }
            },
        };

        foreach (var pkg in packages)
        {
            using (var insertPkg = connection.CreateCommand())
            {
                insertPkg.CommandText = "INSERT INTO QuestionPackages (Name, IsDefault, CreatedAt, UpdatedAt) VALUES (@name, 1, datetime('now'), datetime('now'));";
                insertPkg.Parameters.AddWithValue("@name", pkg.Name);
                insertPkg.ExecuteNonQuery();
            }

            long pkgId;
            using (var lastId = connection.CreateCommand())
            {
                lastId.CommandText = "SELECT last_insert_rowid();";
                pkgId = (long)lastId.ExecuteScalar();
            }

            foreach (var q in pkg.Questions)
            {
                using (var insertQ = connection.CreateCommand())
                {
                    insertQ.CommandText = @"INSERT INTO Questions (QuestionPackageId, QuestionText, Answer1, Answer2, Answer3, CorrectAnswer) 
                                            VALUES (@pkgId, @question, @a1, @a2, @a3, @correct);";
                    insertQ.Parameters.AddWithValue("@pkgId", pkgId);
                    insertQ.Parameters.AddWithValue("@question", q.Q);
                    insertQ.Parameters.AddWithValue("@a1", q.A1);
                    insertQ.Parameters.AddWithValue("@a2", q.A2);
                    insertQ.Parameters.AddWithValue("@a3", q.A3);
                    insertQ.Parameters.AddWithValue("@correct", q.C);
                    insertQ.ExecuteNonQuery();
                }
            }
        }
    }

    private static void AddColumnIfNotExists(SqliteConnection connection, string table, string column, string definition)
    {
        using var cmd = connection.CreateCommand();
        cmd.CommandText = $"PRAGMA table_info({table});";
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            if (reader.GetString(1) == column)
                return;
        }
        reader.Close();

        using var alterCmd = connection.CreateCommand();
        alterCmd.CommandText = $"ALTER TABLE {table} ADD COLUMN {column} {definition};";
        alterCmd.ExecuteNonQuery();
    }
}
