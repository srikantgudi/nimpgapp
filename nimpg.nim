import std/[strformat, strutils, times]
import db_connector/db_postgres

var reccount: int

reccount = 0

# start time
let st = cputime()

# database connection
let dbcon = db_postgres.open("localhost", "postgres", "toor", "northwind")

stdout.write("\nNim DB Demo App\n")

stdout.write("\nPRODUCTS\n")

echo fmt"""{"Id":>6} | {"Product name":-40s} | {"Unit price":10s}"""
echo fmt"""{"-".repeat(6):>6} | {"-".repeat(40):-40s} | {"-".repeat(10):10s}"""

for x in dbcon.fastRows(sql"""select "ProductID","ProductName","UnitPrice" from products"""):
  echo fmt"{x[0]:>6} | {x[1]:-40s} | {parseFloat(x[2]):10.2f}"
  reccount = reccount + 1

echo "\nCUSTOMERS\n"

for x in dbcon.fastRows(sql"""select "CustomerID", "CompanyName", "City" from customers"""):
  echo (fmt"{x[0]:>7} | {x[1]:<40s} | {x[2]:<20s}")
  reccount = reccount + 1

echo "\nORDERS\n"

for x in dbcon.fastRows(sql"""select "OrderID", TO_CHAR("OrderDate",'dd-mm-yyyy'), TO_CHAR("ShippedDate",'dd-mm-yyyy') from orders"""):
  echo (fmt"{x[0]:>7} | {x[1]:<12s} | {x[2]:<12s}")
  reccount = reccount + 1

echo "\nORDER DETAILS\n"

for x in dbcon.fastRows(sql"""Select od."OrderID", p."ProductName", od."Quantity", od."UnitPrice" From order_details od Join products p on p."ProductID" = od."ProductID" """):
  echo (fmt"{x[0]:>7} | {x[1]:<40s} | {parseFloat(x[2]):12.2f} | {parseFloat(x[3]):12.2f}")
  reccount = reccount + 1

echo "\nRelated data from Customers, Orders and Order details\n"
for c in rows(dbcon, sql"""select "CustomerID", "CompanyName", "City" from customers"""):
  echo (fmt"{c[0]:>4} | {c[1]:<40s} | {c[2]:<20s}")
  reccount = reccount + 1

  echo "\nORDERS\n"
  var orderid: string
  for o in rows(dbcon, sql"""select "OrderID", TO_CHAR("OrderDate",'dd-mm-yyyy'), TO_CHAR("ShippedDate",'dd-mm-yyyy') from orders Where "CustomerID" = ?""", c[0]):
    orderid = o[0]
    echo (fmt"{o[0]:>6} | {o[1]:<12s} | {o[2]:<12s}")
    reccount = reccount + 1
    echo "\nORDER DETAILS\n"
    for od in rows(dbcon, sql"""Select od."OrderID", p."ProductName", od."Quantity", od."UnitPrice" From order_details od Join products p on p."ProductID" = od."ProductID" Where od."OrderID" = ? """, orderid):
      echo (fmt"{od[0]:>6} | {od[1]:<40s} | {parseFloat(od[2]):12.2f} | {parseFloat(od[3]):12.2f}")
      reccount = reccount + 1  

echo fmt("\nin app :: Fetched {reccount} records in {(cputime() - st):8.3f}s\n")

# close the connection
dbcon.close()