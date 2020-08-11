      $set sourceformat"free"
      *>Divisão de identificação do programa
       Identification Division.
       Program-id. "jogo_loteria".
       Author. "Michele de Lima.
       Installation. "PC".
       Date-written. 21/07/2020.
       Date-compiled. 11/08/2020.

      *>Divisão para configuração do ambiente
       Environment Division.
       Configuration Section.
           special-names. decimal-point is comma.

      *>-----Declaração dos recursos externos
       Input-output Section.
       File-control.
       I-O-Control.

      *>Declaração de variáveis
       Data Division.

      *>----Variaveis de arquivos
       File Section.


      *>----Variaveis de trabalho
       working-storage section.
       01 ws-aposta.
          05 ws-msn                                pic x(31).
          05 ws-semente                            pic 9(10).
          05 ws-semente1                           pic 9(10).
          05 ws-num_random                         pic 9(02).
          05 ws-resul                              pic 9(02).

       01 ws-numeros-sorteados.
           05 ws-numero                            pic 9(10).

       01 ws-numeros occurs 10.
           05 ws-numeros-sorteio                   pic 9(02)
                                                   value 1.

       01 ws-aposta-inf occurs 10.
          05 ws-aposta-informada                   pic 9(02)
                                                   value 1.

       01 ws-acertos occurs 10.
           05 ws-acertou                           pic 9(02)
                                                   value 1.

       01 ws-hora-inicio.
           05 ws-hor                               pic 9(002).
           05 ws-min                               pic 9(002).
           05 ws-seg                               pic 9(002).

       01 ws-hora-final.
           05 ws-hor-fim                           pic 9(002).
           05 ws-min-fim                           pic 9(002).
           05 ws-seg-fim                           pic 9(002).

       01 ws-indices.
           05 ws-aposta-ind                        pic 9(02)
                                                   value 1.
           05 ws-qnt-aposta-ind                    pic 9(02)
                                                   value 1.
           05 ws-ind-random                        pic 9(02).
           05 ws-ind-acertos                       pic 9(02)
                                                   value 1.
           05 ws-ind-comparar                      pic 9(02)
                                                   value 0.
           05 ws-ind-sorte                         pic 9(02)
                                                   value 1.
           05 ws-contador                          pic 9(04)
                                                   value 0.
           05 ws-ind-acertou                       pic 9(02).


       77 ws-diferenca-hr                          pic 9(02).
       77 ws-diferenca-min                         pic 9(02).
       77 ws-diferenca-seg                         pic 9(02).

       77 ws-sair                                  pic x(02).

       77 ws-menu                                  pic 9(02).

       linkage section.


      *>----Declaração de tela
       screen section.

      *>É necessario relacionar as variaveis da Linkage section
      *>para se tornarem acessiveis ao programa...
       procedure division.


      *>É necessario relacionar as variaveis da Linkage section
      *>para se tornarem acessiveis ao programa...

           perform inicializa.
           perform processamento.
           perform finaliza.

      *>Inicilizacao de variaveis, abertura de arquivos
      *>procedimentos que serao realizados apenas uma vez
       inicializa section.
           .
       inicializa-exit.
           exit.

      *>construçao do laço principal (menu) ou regra de negócio
       processamento section.

           *>função para saber a hora que inicia o jogo de aposta
           move function current-date(9:6) to ws-hora-inicio


           perform until ws-sair = "S"
                      or ws-sair = "s"
               display erase

               display "     Jogo de Apostas      "
               display "                          "
               display "'6'  Apostar 6 numeros?   "
               display "'7'  Apostar 7 numeros?   "
               display "'8'  Apostar 8 numeros?   "
               display "'9'  Apostar 9 numeros?   "
               display "'10' Apostar 10 numeros?  "
               accept ws-menu
                   if ws-menu >= 6 and ws-menu <= 10 then
                       perform aposta
                   else
                       display "opcao invalida"
                   end-if

               move 1  to ws-qnt-aposta-ind

               display "'S'air"
               accept ws-sair
           end-perform
           .
       processamento-exit.
           exit.


      *>--------------------------Quantidade de apostas--------------------------------------

       aposta section.

           move 1 to ws-aposta-ind
           perform until ws-qnt-aposta-ind > ws-menu
               display "Informe sua aposta com numeros de 1 a 60: "
               accept ws-aposta-ind
                   if ws-aposta-ind > 0 and ws-aposta-ind <= 60 then
                       move ws-aposta-ind to ws-aposta-informada(ws-qnt-aposta-ind)
                       add 1 to ws-qnt-aposta-ind
                   else
                       display "Os numeros devem ser de 1 a 60, informe novamente: "
                       accept ws-aposta-ind
                   end-if
           end-perform
      *>   chama o sorteio de números
           perform sortear

           .
       aposta-exit.
           exit.

      *>--------------------Atraso da semente - Delay---------------------------------------

       semente-delay section.  *> delay de 1 centésimo de segundo
           perform 10 times

               accept ws-semente1 from time
               move ws-semente1   to ws-semente

               perform until ws-semente > ws-semente1
                   accept ws-semente from time
               end-perform
           end-perform
           .
       semente-delay-exit.
           exit.

      *>--------------------Sorteia numeros aleatorios--------------------------------------
       sortear section.

           move 0  to ws-ind-acertou

           perform until ws-ind-acertou > 0

               add  1 to ws-contador
               move 1 to ws-ind-random

               perform until ws-ind-random > 6

                   perform semente-delay

                   compute ws-num_random = function random(ws-semente) * 60

                   if  (ws-num_random > 0) and (ws-num_random <= 60)
                   and ws-num_random <> ws-numeros-sorteio(1)
                   and ws-num_random <> ws-numeros-sorteio(2)
                   and ws-num_random <> ws-numeros-sorteio(3)
                   and ws-num_random <> ws-numeros-sorteio(4)
                   and ws-num_random <> ws-numeros-sorteio(5)
                   and ws-num_random <> ws-numeros-sorteio(6) then
                       move ws-num_random to ws-numeros-sorteio(ws-ind-random)
                       add 1 to ws-ind-random
                   end-if
               end-perform

      *>----------------------Comparação entre os numeros -----------------------------------
               perform varying ws-ind-comparar from 1 by 1 until ws-ind-comparar = 6

                   if ws-aposta-informada(ws-ind-comparar) = ws-numeros-sorteio(1)
                   or ws-aposta-informada(ws-ind-comparar) = ws-numeros-sorteio(2)
                   or ws-aposta-informada(ws-ind-comparar) = ws-numeros-sorteio(3)
                   or ws-aposta-informada(ws-ind-comparar) = ws-numeros-sorteio(4)
                   or ws-aposta-informada(ws-ind-comparar) = ws-numeros-sorteio(5)
                   or ws-aposta-informada(ws-ind-comparar) = ws-numeros-sorteio(6)then
                      move ws-aposta-informada(ws-ind-comparar) to ws-acertou(ws-ind-comparar)
                   end-if
               end-perform

      *>Tratamento para informar usuário
               if  ws-acertou(1) = ws-numeros-sorteio(1)
               and ws-acertou(2) = ws-numeros-sorteio(2)
               and ws-acertou(3) = ws-numeros-sorteio(3)
               and ws-acertou(4) = ws-numeros-sorteio(4)
               and ws-acertou(5) = ws-numeros-sorteio(5)
               and ws-acertou(6) = ws-numeros-sorteio(6) then
                   display "Voce acertou, parabens!!"

                   *>função para saber a hora final após ter acertado
                   move function current-date(9:6) to ws-hora-final

                   *>os numeros sorteados
                   display "                       "
                   display "Os numeros sorteados foram: "ws-numeros-sorteio(1)" "ws-numeros-sorteio(2)
                           " "ws-numeros-sorteio(3)" "ws-numeros-sorteio(4)" "ws-numeros-sorteio(5)
                           " "ws-numeros-sorteio(6)

                   *>o tempo gasto para acertar
                   perform tempo-gasto
                   display "Voce levou "ws-diferenca-hr" hrs, "
                   display ws-diferenca-min" min e "
                   display ws-diferenca-seg" seg para acertar."

                   *>qnt de apostas feitas até acertar
                   display "                       "
                   display "Voce apostou: " ws-contador " vezes até acertar"
                   move 1 to ws-ind-acertou
               else
                   display "                       "
                   display "Voce ainda nao acertou."
                   display "Os numeros sorteados foram: "ws-numeros-sorteio(1)" "ws-numeros-sorteio(2)
                           " "ws-numeros-sorteio(3)" "ws-numeros-sorteio(4)" "ws-numeros-sorteio(5)
                           " "ws-numeros-sorteio(6)
                   display "A aposta esta em: " ws-contador " vezes"
                   display "                       "
               end-if
           end-perform

           .
       sortear-exit.
           exit.

      *>----------------------calculo do tempo gasto no jogo--------------------------------

       tempo-gasto section.

           compute ws-diferenca-hr  = (ws-hor - ws-hor-fim)
           compute ws-diferenca-min = (ws-min - ws-min-fim)
           compute ws-diferenca-seg = (ws-seg - ws-seg-fim)

           .
       tempo-gasto-exit.
           exit.

      *>-------------------------------------------------------------------------------------
       finaliza section.
           display "Sistema finalizado."

           stop run

           .
       finaliza-exit.
           exit.



