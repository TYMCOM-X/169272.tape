!tar -cvf fta3: (tymnet)*.t??.*.c??
 tarfile: fta3:
file:  (tymnet)*.t??.*.c??
./tymnet/init.tba                   121
./tymnet/nd4514.tym                1394
./tymnet/nodes.txt                11823
./tymnet/bk4514.tym                1369
./tymnet/sort.ctl                   115
./tymnet/nd4514.cmd                 227
./tymnet/nodes.cmd                   43
./tymnet/nodes.ctl                  559
./tymnet/node95.ctl                 282

(/tartest) root@gemini# tar -tv
----------1367/9023      0 Dec 31 16:00 1969 ./tymnet/
----------1367/9023    121 Dec 31 16:00 1969 ./tymnet/init.tba
----------1367/9023   1394 Dec 31 16:00 1969 ./tymnet/nd4514.tym
----------1367/9023  11823 Dec 31 16:00 1969 ./tymnet/nodes.txt
----------1367/9023   1369 Dec 31 16:00 1969 ./tymnet/bk4514.tym
----------1367/9023    115 Dec 31 16:00 1969 ./tymnet/sort.ctl
----------1367/9023    227 Dec 31 16:00 1969 ./tymnet/nd4514.cmd
----------1367/9023     43 Dec 31 16:00 1969 ./tymnet/nodes.cmd
----------1367/9023    559 Dec 31 16:00 1969 ./tymnet/nodes.ctl
----------1367/9023    282 Dec 31 16:00 1969 ./tymnet/node95.ctl

(/tartest) root@gemini# tar -xv .
x ./tymnet/init.tba, 121 bytes, 1 tape blocks
x ./tymnet/nd4514.tym, 1394 bytes, 3 tape blocks
x ./tymnet/nodes.txt, 11823 bytes, 24 tape blocks
x ./tymnet/bk4514.tym, 1369 bytes, 3 tape blocks
x ./tymnet/sort.ctl, 115 bytes, 1 tape blocks
x ./tymnet/nd4514.cmd, 227 bytes, 1 tape blocks
x ./tymnet/nodes.cmd, 43 bytes, 1 tape blocks
x ./tymnet/nodes.ctl, 559 bytes, 2 tape blocks
x ./tymnet/node95.ctl, 282 bytes, 1 tape blocks

(/tartest) root@gemini# ls -alFR tymnet
drwxrwsr-x  2 -1367         512 Dec 31  1969 tymnet/

tymnet:
total 24
drwxrwsr-x  2 -1367         512 Dec 31  1969 ./
drwxrwsr-x  3 root          512 May 17 02:34 ../
----------  1 -1367        1369 Dec 31  1969 bk4514.tym
----------  1 -1367         121 Dec 31  1969 init.tba
----------  1 -1367         227 Dec 31  1969 nd4514.cmd
----------  1 -1367        1394 Dec 31  1969 nd4514.tym
----------  1 -1367         282 Dec 31  1969 node95.ctl
----------  1 -1367          43 Dec 31  1969 nodes.cmd
----------  1 -1367         559 Dec 31  1969 nodes.ctl
----------  1 -1367       11823 Dec 31  1969 nodes.txt
----------  1 -1367         115 Dec 31  1969 sort.ctl

 