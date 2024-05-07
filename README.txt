# Grafové Databáze

Repozitář pro bakalářskou práci zaměřenou na grafové databáze.

## Zvolené implementace

* OrientDB
* Neo4j
* ArangoDB

## Obsah

* Složky `*-docker` obsahují potřebné soubory pro sestavení Dockerových obrazů pro jednotlivé implementace.
* Složka `kidiplom` obsahuje textový dokument.
* Složka `queries` obsahuje podsložky s používanými dotazy pro jednotlivé implementace. 
  - Soubory s dotazy Cypher (používané v Neo4j)
  - Soubory s dotazy Gremlin (používané s OrientDB)
  - Soubory s dotazy AQL (používané v ArangoDB)
  - Soubory s dotazy OrientDB SQL (používané v OrientDB)
  - Soubory s dotazy pro algoritmy Neo4j
* Složka `images` s obrázky sloužícími jako návody.
* Soubor `Measurements.xlsx` s výsledky experimentů.

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
sh /youtube-import-test.sh
sh /youtube-properties-import.sh
```

Po importování se zobrazí čas importování pro vrcholy a hrany.

Gremlin Console `gremlin.sh` je umístěna v kontejneru ve složce `/orientdb/bin/`. Pro připojení k databázi s názvem *<SELECTED_DATABASE>* v konzoli lze použít následující příkaz:

```groovy
//OrientDb database connector
graph = OrientGraph.open("plocal:/orientdb/databases/<SELECTED_DATABASE>", "root", "root");

//establishing a graph traversal source object
g = graph.traversal();
```

Připojení k databázi je doprovázeno několika errory sdělujícími, že je databáze uzamknuta jiným procesem. Na funkčnost nemají vliv. Někdy též se k databázi nepovedlo přihlásit a pomohlo až restartování kontejneru.
Při přidávání vlastností se tiskne asi každou milisekundu:

```bash
SEVER {db=Youtube} input type not supported::  class java.lang.Integer [OETLOrientDBLoader]
```

Ale změna vlastností proběhne v pořádku. Změna vlastností trvá podobný čas jako přidání hran.

Je však doporučeno použít inicializační soubory k připojení k databázi s názvem *<SELECTED_DATABASE>*, které se nacházejí v kontejneru ve složce `/init-files-gremlin/`. Příkaz pro připojení v interaktivním shellu kontejneru je:

```bash
/orientdb/bin/gremlin.sh -i /init-files-gremlin/<SELECTED_DATABASE>.groovy -Xmx4g
```

Tyto soubory obsahují funkce s předpřipravenými dotazy, které jsou pro používání pohodlnější. Seznam těchto funkcí lze zobrazit pomocí funkce `help()`. Každá funkce má jako první parametr `g`, který je instancí objektu pro procházení grafu. Pro databázi s názvem __Youtube__ funkce vrací řetězec s výsledkem a časem běhu dotazu.

Na některé funkce lze navázat například funkci `count()` a zjistit tak počet vrácených výsledků. Příklad:

```groovy
gremlin> searchUsers(g)
==>[userId:[153],firstName:[Ashley],lastName:[Roberts]]
==>[userId:[146],firstName:[Kathryn],lastName:[Robbins]]
==>[userId:[226],firstName:[Zachary],lastName:[Roberts]]
==>[userId:[228],firstName:[Robert],lastName:[Parker]]
==>[userId:[252],firstName:[Robert],lastName:[Murphy]]
==>[userId:[189],firstName:[Robert],lastName:[Willis]]
==>[userId:[229],firstName:[Robin],lastName:[Myers]]
==>[userId:[238],firstName:[Robin],lastName:[Rivera]]
==>[userId:[71],firstName:[Marie],lastName:[Robertson]]
==>[userId:[8],firstName:[Robert],lastName:[Fuller]]
gremlin> searchUsers(g).count()
==>10
```

Pro použití *lightweight hran* v databázi je nutné použít nový kontejner pro OrientDB (na stejném se mi to nepodařilo zprovoznit) a nastavit v JSON souborech umístěných v kontejneru ve složce `/import/Youtube` parametr `useLightweightEdges` na `true`. Databáze i přes nastavení parametru vkládala regulární hrany. Proto jsem postupoval následovně. V interaktivním shellu kontejneru jsem zadal příkaz pro importování vrcholů:

```bash
/orientdb/bin/oetl.sh /import/Youtube/users.json
```

Následně jsem databázi otevřel v OrientDB Studiu a nastavil `useLightweightEdges` pomocí checkbuttonu a uložil. Postup je znázorněn na obrázku `/images/orientdb-lightweight-edges.png`:
![Nastavení lightweight hran v OrientDB Studiu](/images/orientdb-lightweight-edges.png)
Následně jsem zastavil a rozběhnul Docker kontejner a přidal hrany:

```bash
/orientdb/bin/oetl.sh /import/Youtube/friends.json
```

Po importování hran, které proběhlo v pořádku, by v OrientDB Studiu měl být počet hran s labelem `FRIENDS` nastaven na 0, jak na obrázku `/orientdb-lightweight-edges-2.png`:
![Počet hran při použití lightweight hran by měl být 0](/images/orientdb-lightweight-edges-2.png)
Hrany jsou takto uloženy pouze jako odkazy ve vrcholech.

### Neo4j

Vytvořte Docker kontejner pomocí příkazů:

```bash
docker build -t neo4j-database:1.0 .
docker run -p 7474:7474 -p 7687:7687 neo4j-database:1.0
```

Neo4j Browser je dostupný na IP adrese http://localhost:7474. Není zde potřeba žádných přihlašovacích údajů, neboť autentifikace je nastavena na `none`.

Vytvoření databáze se jménem *<DATABASE_NAME>* v Neo4j Browseru se provádí příkazem:

```cypher
CREATE DATABASE <DATABASE_NAME>
```

Jsou potřeba vytvořit tyto čtyři databáze: __travelenthusiastnetwork__, __railnetwork__, __youtube__ a jedna pro testování algoritmů.

Zvolení databáze se jménem *<DATABASE_NAME>* se provádí příkazem:

```cypher
:use <DATABASE_NAME>
```

Data lze importovat do vybrané databáze v Neo4j Browseru pomocí zkopírování Cypher souborů nacházejících se v kontejneru ve složce `/import/`. Případně v repozitáři ve složce `/Neo4j-docker/import/`. Tato metoda byla také použita při testování importování pro každý dotaz zvlášť. Neo4j Browser pro každý spuštěný dotaz vrací i čas běhu.

V dotazech Cypher jsou používány parametry. Hodnoty *y1,...,yn* parametrů `x1,...,xn` lze specifikovat příkazem:

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
sh /import.sh
```

Pro testování importování dat do databáze __Youtube__ použijte v interaktivním shellu kontejneru příkazy:

```bash
sh /youtube-import-test.sh
sh /youtube-properties-import.sh
```

Po importování se zobrazí čas importování pro vrcholy a hrany.

V dotazech AQL jsou používány parametry. Příklad jejich použití je ukázán na obrázku, který se nachází v repozitáři ve složce `/arangodb-example.png`. Do textové části vyznačené modrým obdélníkem se píší dotazy a do části označené červeným obdélníkem se píší parametry. Jako hodnoty parametrů se volí `_id` atribut požadovaného vrcholu. Tedy např. `"User/10"`. U některých dotazů je též vyžadováno pole řetězců. Tedy např. `["string1", "string2"]`.
![Použití parametrů v databázi ArangoDB](/images/arangodb-example.png)