# Grafové Databáze
Repozitář pro bakalářskou práci zaměřenou na grafové databáze.

## Obsah
* Složky `*-docker` obsahují potřebné soubory pro sestavení Dockerových obrazů.
* Složka `kidiplom` obsahuje aktuální verzi textového dokumentu.
* Složka `queries` zahrnuje dotazy pro různá datová soubory zmíněná v textovém dokumentu.
  - Soubory s dotazy Cypher
  - Soubory s dotazy Gremlin
  - Soubory s dotazy AQL
  - Soubory s dotazy OrientDB SQL
  - Soubory s dotazy pro algoritmy Neo4j
* Soubor `Measurements.xlsx` s výsledky experimentů.

## Zvolené implementace
* OrientDB
* Neo4j
* ArangoDB

## Databáze
V praktické části jsem v každé implementaci pracoval s nejvýše čtyřmi databázemi:
* `TravelEnthusiastNetwork`
* `RailNetwork`
* `Youtube`
* databáze pro zkoušení algoritmů 
  - pouze v Neo4j

## Spuštění Dockeru

### OrientDB
Vytvořte Docker kontejner pomocí příkazů:
```bash
docker build -t orientdb-database:1.0 .
docker run -p 2480:2480 orientdb-database:1.0
```
OrientDB Studio je dostupné na IP adrese http://localhost:2480. Přihlašovací údaje jsou nastaveny na `root`. Databáze __TravelEnthusiastNetwork__ a __RailNetwork__ jsou načteny automaticky při vytváření Docker obrazu. Pro testování importování v OrientDB použijte v interaktivním shellu kontejneru následující příkazy:
```bash
sh youtube-import-test.sh
sh youtube-properties-import.sh
```
Po importování se zobrazí čas importování pro vrcholy a hrany.

Gremlin Console `gremlin.sh` je umístěna v kontejneru ve složce `/orientdb/bin/`. Pro připojení k databázi s názvem _<SELECTED_DATABASE>_ v konzoli lze použít následující příkaz:
```groovy
//OrientDb database connector
graph = OrientGraph.open("plocal:/orientdb/databases/<SELECTED_DATABASE>", "root", "root");

//establishing a graph traversal source object
g = graph.traversal();
```

Je však doporučeno použít inicializační soubory k připojení k databázi s názvem _<SELECTED_DATABASE>_, které se nacházejí v kontejneru ve složce `/init-files-gremlin/`. Příkaz pro připojení v interaktivním shellu kontejneru je:
```bash
/orientdb/bin/gremlin.sh -i /init-files-gremlin/<SELECTED_DATABASE>.groovy -Xmx4g
```
Tyto soubory obsahují funkce s předpřipravenými dotazy, které jsou pro používání pohodlnější. Seznam těchto funkcí lze zobrazit pomocí funkce `help()`. :warning: Každá funkce má jako první parametr `g`. Pro databázi s názvem __Youtube__ funkce vrací čas běhu dotazů.

Pro použití _lightweight hran_ v databázi je nutné nastavit v JSON souborech umístěných v kontejneru ve složce `/import/Youtube` parametr `useLightweightEdges` na `true` před importováním databáze __Youtube__. Pokud databázi importujete do stejného Docker kontejneru, je nutné též změnit název databáze nastavením parametru `dbURL` na `plocal:../databases/<NEW_DATABASE_NAME>`.

### Neo4j
Vytvořte Docker kontejner pomocí příkazů:
```bash
docker build -t neo4j-database:1.0 .
docker run -p 7474:7474 -p 7687:7687 neo4j-database:1.0
```

Neo4j Browser je dostupný na IP adrese http://localhost:7474. Není zde potřeba žádných přihlašovacích údajů, neboť autentifikace je nastavena na `none`.

Vytvoření databáze se jménem _<DATABASE_NAME>_ v Neo4j Browseru se provádí příkazem:
```cypher
CREATE DATABASE <DATABASE_NAME>
```
Jsou potřeba vytvořit tyto čtyři databáze: __travelenthusiastnetwork__, __railnetwork__, __youtube__ a jedna pro testování algoritmů.

Zvolení databáze se jménem _<DATABASE_NAME>_ se provádí příkazem:
```cypher
:use <DATABASE_NAME>
```

Data lze importovat do vybrané databáze v Neo4j Browseru pomocí zkopírování Cypher souborů nacházejících se v kontejneru ve složce `/import/`. Případně v repozitáři ve složce `/Neo4j-docker/import/`. Tato metoda byla také použita při testování importování pro každý dotaz zvlášť. Neo4j Browser pro každý spuštěný dotaz vrací i čas běhu.

V dotazech Cypher jsou používány parametry. Hodnoty _y1,...,yn_ parametrů `x1,...,xn` lze specifikovat příkazem:
```cypher
:params 
{
    "x1": y1,
    ...,
    "xn": yn
}
```

### ArangoDB
Vytvořte Docker kontejner pomocí příkazů:
```bash
docker build -t arangodb-database:1.0 . 
docker run -p 8529:8529 arangodb-database:1.0
```

ArangoDB Web Interface je dostupné na IP adrese http://localhost:8529. Přihlašovací údaje jsou nastaveny na `root`.

Databáze __TravelEnthusiastNetwork__ a __RailNetwork__ lze importovat v interaktivním shellu kontejneru pomocí příkazu
```bash
sh import.sh
```
Pro testování importování dat do databáze __Youtube__ použijte v interaktivním shellu kontejneru příkazy:
```bash
sh youtube-import-test.sh
sh youtube-properties-import.sh
```
Po importování se zobrazí čas importování pro vrcholy a hrany.

V dotazech AQL jsou používány parametry. Příklad jejich použití je ukázán na obrázku, který se nachází v repozitáři ve složce `/arangodb-example.png`. Do textové části vyznačené modrým obdélníkem se píší dotazy a do části označené červeným obdélníkem se píší parametry. Jako hodnoty parametrů se volí `_id` atribut požadovaného vrcholu. Tedy např. `"User/10"`. U některých dotazů je též vyžadováno pole řetězců. Tedy např. `["string1", "string2"]`.
![Image Alt text](/arangodb-example.png)