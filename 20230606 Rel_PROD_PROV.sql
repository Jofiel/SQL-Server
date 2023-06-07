select * from bprprvpd a
inner join bpcprv b on b.e1neno=a.e1nenoprv and b.l2nprv=a.l2nnmrprv
inner join bpcprd c on a.c3ncdgprd=c.v1nprd