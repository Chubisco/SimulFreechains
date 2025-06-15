#!/bin/bash

#set -x

#mata os hosts antigos antes de uma nova simulação
killall -q freechains-host
rm -rf /tmp/myhost1 /tmp/myhost2 /tmp/myhost3

# Inicia 3 hosts em portas distintas
freechains-host start /tmp/myhost1 --port=8551 &	# & é pra rodar em segundo plano
freechains-host start /tmp/myhost2 --port=8552 &
freechains-host start /tmp/myhost3 --port=8553 &

# Função para mostrar reputação dos usuários
mostrar_reputacao() {
    local momento=$1
    echo "===== REPUTAÇÕES $momento ====="
    for USER in "Jorge" "Matheus" "Gabriela" "Francisco" "Rafaela"; do
        # Pegando a variável PUB correspondente
        case $USER in
            Jorge) PUB=$PUB1 ;;
            Matheus) PUB=$PUB2 ;;
            Gabriela) PUB=$PUBNoob ;;
            Francisco) PUB=$PUBAtivo ;;
            Rafaela) PUB=$PUBTroll ;;
        esac
        echo "Reputação de $USER: $(freechains chain '#batepapo' reps $PUB --port=8551)"
    done
    echo ""
}

sleep 1		# espera um segundo antes de continuar

# Criação das chaves para cada usuário
CHAVES=$(freechains keys pubpvt "pioneiro1" --port=8551) #Jorge
PUB1=$(echo "$CHAVES" | cut -d' ' -f1)
PVT1=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "pioneiro2" --port=8551) #Matheus
PUB2=$(echo "$CHAVES" | cut -d' ' -f1)
PVT2=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "noob" --port=8552) #Gabriela
PUBNoob=$(echo "$CHAVES" | cut -d' ' -f1)
PVTNoob=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "userativo" --port=8552) #Francisco
PUBAtivo=$(echo "$CHAVES" | cut -d' ' -f1)
PVTAtivo=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "troll" --port=8553) #Rafa
PUBTroll=$(echo "$CHAVES" | cut -d' ' -f1)
PVTTroll=$(echo "$CHAVES" | cut -d' ' -f2)

# criação do forum
freechains chains join '#batepapo' "$PUB1" "$PUB2" --port=8551

# semana 0 (dias 0-7)
freechains-host now 0 --port=8551
freechains-host now 0 --port=8552
freechains-host now 0 --port=8553

# Jorge posta uma apresentação ao forum
POST1=$(freechains chain '#batepapo' post inline 'Sejam bem-vindes ao novo fórum! A única regra é o bom senso -JorgeJabuti' --sign=$PVT1 --port=8551 2>/dev/null)
# Matheus complementa a apresentação
POST2=$(freechains chain '#batepapo' post inline 'Eu e o Jorge criamos esse espaço pra que todes pudessem conversar de forma livre e segura, mas sempre com respeito. Espero que aproveitem! -MatheusDaMassa' --sign=$PVT2 --port=8551 2>/dev/null)

mostrar_reputacao "NO FIM DA SEMANA 1"

# semana 1 (dias 7-14)
freechains-host now 604800000 --port=8551
freechains-host now 604800000 --port=8552
freechains-host now 604800000 --port=8553

# Francisco (user ativo) entra no forum e sincroniza com os hosts (Gabrie, noob, também, por ser do mesmo nó)
freechains chains join '#batepapo' "$PUB1" "$PUB2" --port=8552
freechains --host=localhost:8552 peer localhost:8551 recv '#batepapo' --port=8552

# Francisco faz sua primeira postagem e a envia
POST3=$(freechains chain "#batepapo" post inline 'Oi gente! Parece que eu fui o primeiro a chegar haha! -Francisco' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# semana 2 (dias 14-21)
freechains-host now 1209600000 --port=8551
freechains-host now 1209600000 --port=8552
freechains-host now 1209600000 --port=8553

# Rafaela (troll) entra no forum
freechains chains join '#batepapo' "$PUB1" "$PUB2" --port=8553 # Troll

# Rafaela faz uma postagem ofensiva e se sincroniza com o forum
freechains --host=localhost:8553 peer localhost:8551 recv '#batepapo' --port=8553
POST4=$(freechains chain "#batepapo" post inline 'Vocês todos são idiotas HAHAHAHAHA -4NG3L 0F TH3 N1GTH' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#batepapo' --port=8553

# Gabriela (noob) faz uma pergunta
POST5=$(freechains chain "#batepapo" post inline 'Sou nova aqui, como funciona? -Gabriela' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#batepapo' --port=8552

# Francisco faz mais uma postagem e a envia
POST6=$(freechains chain "#batepapo" post inline 'Eai Gabriela! Finalmente você veio, pode ficar tranquila que eu te ensino as coisas.' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#batepapo' --port=8552

# Jorge dá like na resposta do Francisco
freechains chain "#batepapo" like $POST6 --sign=$PVT1 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#batepapo' --port=8551

mostrar_reputacao "NO FIM DA SEMANA 2"

# semana 3 (dias 21-28)
freechains-host now 1814400000 --port=8551
freechains-host now 1814400000 --port=8552
freechains-host now 1814400000 --port=8553

# Matheus responde Gabriela e da like em sua mensagem
POST7=$(freechains chain "#batepapo" post inline 'Bem-vinda Gabriela! É só postar e votar. E pode ignorar esse maluco 4NG3l-sei-la-o-que ai...' --sign=$PVT2 --port=8551 2>/dev/null)
freechains chain "#batepapo" like $POST5 --sign=$PVT2 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#batepapo' --port=8551

# Jorge e Matheus dão deslike na postagem da Rafaela
freechains chain "#batepapo" dislike $POST4 --sign=$PVT1 --port=8551
freechains chain "#batepapo" dislike $POST4 --sign=$PVT2 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#batepapo' --port=8551

# Jorge faz uma nova postagem
POST8=$(freechains chain "#batepapo" post inline 'Que bom ver mais gente entrando no forum, mas vamos lembrar de manter um ambiente respeituoso' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#batepapo' --port=8551

# Rafaela faz uma postagem de spam
POST9=$(freechains chain "#batepapo" post inline 'TRAVA ZAP TRAVA ZAP TRAVA ZAP -4NG3L 0F TH3 N1GTH' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#batepapo' --port=8553

mostrar_reputacao "NO FIM DA SEMANA 3"

# semana 4 (dias 28-35)
freechains-host now 2419200000 --port=8551
freechains-host now 2419200000 --port=8552
freechains-host now 2419200000 --port=8553

# Gabriela (noob) faz uma nova postagem
POST10=$(freechains chain "#batepapo" post inline 'Obrigado pela recepção gente! Vou aprendendo devagar kkk' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#batepapo' --port=8552

# Francisco faz mais uma postagem
POST11=$(freechains chain "#batepapo" post inline 'A gente não consegue tirar esse maluco daqui? Mas mudando de assunto... vocês jogam alguma coisa? tipo videogames' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#batepapo' --port=8552

# Jorge e Matheus dão deslike na nova postagem da Rafaela e Jorge responde ao Francisco e dá like em sua última postagem
freechains chain "#batepapo" dislike $POST9 --sign=$PVT1 --port=8551
freechains chain "#batepapo" dislike $POST9 --sign=$PVT2 --port=8551

POST12=$(freechains chain "#batepapo" post inline 'Vamos pensar em alguma forma de lidar com isso, se tiver alguma ideia pode falar!' --sign=$PVT1 --port=8551 2>/dev/null)
POST13=$(freechains chain "#batepapo" post inline 'Eu e o Matheus estavamos tentando jogar Elden Ring recentemente! (ênfase em tentando kkkkk) Você curte esse tipo de jogo Francisco?' --sign=$PVT1 --port=8551 2>/dev/null)
freechains chain "#batepapo" like $POST11 --sign=$PVT2 --port=8551

freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#batepapo' --port=8551

# Rafaela faz uma postagem de spam
POST14=$(freechains chain "#batepapo" post inline 'BURROS IDIOTAS SEU CHATOS FEDIDOS -4NG3L 0F TH3 N1GTH' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#batepapo' --port=8553

mostrar_reputacao "NO FIM DA SEMANA 4"

# semana 5 (dias 35-42)
freechains-host now 3024000000 --port=8551
freechains-host now 3024000000 --port=8552
freechains-host now 3024000000 --port=8553

# Francisco faz mais uma postagem
POST15=$(freechains chain "#batepapo" post inline 'Puts! Ouvi dizer que era muito bom mas MUITO dificil; nunca joguei. E sobre o "amigo"... e se a gente só ignorasse essa pessoa?' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552
#Francisco para de dar SEND pro port 8553, do Troll

# Matheus responde Francisco e dá deslike nas postagens da Rafaela
POST16=$(freechains chain "#batepapo" post inline 'É bem dificil KKKK mas isso faz parte da diversão!' --sign=$PVT2 --port=8551 2>/dev/null)
POST17=$(freechains chain "#batepapo" post inline 'Podemos tentar ignorar, enquanto isso vou dar deslike pra limitar as ações dessa pessoa...' --sign=$PVT2 --port=8551 2>/dev/null)
freechains chain "#batepapo" dislike $POST14 --sign=$PVT2 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

mostrar_reputacao "NO FIM DA SEMANA 5"

# semana 6 (dias 42-49)
freechains-host now 3628800000 --port=8551
freechains-host now 3628800000 --port=8552
freechains-host now 3628800000 --port=8553

# Jorge faz mais uma postagem
POST18=$(freechains chain "#batepapo" post inline 'Postagem 18' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

# Matheus responde Jorge
POST19=$(freechains chain "#batepapo" post inline 'Resposta sobre o jogo' --sign=$PVT2 --port=8551 2>/dev/null)
POST20=$(freechains chain "#batepapo" post inline 'Resposta sobre o Troll' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

# Francisco responde e da like nas mensagens de Jorge e Matheus
POST21=$(freechains chain "#batepapo" post inline 'Resposta do Francisco' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains chain "#batepapo" like $POST18 --sign=$PVTAtivo --port=8552
freechains chain "#batepapo" like $POST19 --sign=$PVTAtivo --port=8552
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

mostrar_reputacao "NO FIM DA SEMANA 6"

# semana 7 (dias 49-56)
freechains-host now 4233600000 --port=8551
freechains-host now 4233600000 --port=8552
freechains-host now 4233600000 --port=8553

# Francisco faz uma postagem
POST22=$(freechains chain "#batepapo" post inline 'Postagem sobre alguma coisa' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Gabriela (noob) faz uma nova postagem respondendo Francisco
POST23=$(freechains chain "#batepapo" post inline 'Gabriela volta pro forum' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Jorge e Matheus se surpreendem com o aparecimento de Gabriela no chat
POST24=$(freechains chain "#batepapo" post inline 'Bem vinda de volta Gabriela!' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

POST25=$(freechains chain "#batepapo" post inline 'Uau! Bem vinda de volta Gabriela!' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

mostrar_reputacao "NO FIM DA SEMANA 7"

# semana 8 (dias 56-63)
freechains-host now 4838400000 --port=8551
freechains-host now 4838400000 --port=8552
freechains-host now 4838400000 --port=8553

# Gabriela (noob) faz uma nova postagem
POST26=$(freechains chain "#batepapo" post inline 'Gabriela pergunta algo' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Francisco responde Gabriela e dá like em sua mensagem
POST27=$(freechains chain "#batepapo" post inline 'Resposta sobre algo' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552
freechains chain "#batepapo" like $POST26 --sign=$PVTAtivo --port=8552

# Rafaela se sincroniza, pois pararam de lhe enviar atualizações, e faz uma postagem de spam
freechains --host=localhost:8553 peer localhost:8551 recv '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 recv '#batepapo' --port=8553
POST28=$(freechains chain "#batepapo" post inline 'Vocês são todos uns nerds sem vida, isso aqui é inútil -4NG3L 0F TH3 N1GTH' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#batepapo' --port=8553

mostrar_reputacao "NO FIM DA SEMANA 8"

# semana 9 (dias 63-70)
freechains-host now 5443200000 --port=8551
freechains-host now 5443200000 --port=8552
freechains-host now 5443200000 --port=8553

# Jorge e Matheus respondem Francisco e Gabriela
POST29=$(freechains chain "#batepapo" post inline 'Resposta a Gabriela' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

POST30=$(freechains chain "#batepapo" post inline 'Matheus batendo papo' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

# Francisco continua a conversa
POST31=$(freechains chain "#batepapo" post inline 'Francisco batendo papo' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

mostrar_reputacao "NO FIM DA SEMANA 9"

# semana 10 (dias 70-77)
freechains-host now 6048000000 --port=8551
freechains-host now 6048000000 --port=8552
freechains-host now 6048000000 --port=8553

# Francisco continua a conversa
POST32=$(freechains chain "#batepapo" post inline 'Francisco batendo papo' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Gabriela (noob) faz uma nova postagem
POST33=$(freechains chain "#batepapo" post inline 'Gabriela pergunta algo' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

mostrar_reputacao "NO FIM DA SEMANA 10"

# semana 11 (dias 77-84)
freechains-host now 6652800000 --port=8551
freechains-host now 6652800000 --port=8552
freechains-host now 6652800000 --port=8553

# Francisco continua a conversa
POST34=$(freechains chain "#batepapo" post inline 'Francisco batendo papo' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Jorge
POST35=$(freechains chain "#batepapo" post inline 'Resposta' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

mostrar_reputacao "NO FIM DA SEMANA 11"

# semana 12 (dias 84-91)
freechains-host now 7257600000 --port=8551
freechains-host now 7257600000 --port=8552
freechains-host now 7257600000 --port=8553

# Gabriela (noob) faz uma nova postagem se despedindo do forum
POST36=$(freechains chain "#batepapo" post inline 'Gabriela se despedindo' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Francisco continua a conversa se despedindo do forum
POST37=$(freechains chain "#batepapo" post inline 'Francisco se despedindo' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#batepapo' --port=8552

# Jorge e Matheus respondem Francisco e Gabriela agradecendo pela participação
POST38=$(freechains chain "#batepapo" post inline 'Jorge agradecendo' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

POST39=$(freechains chain "#batepapo" post inline 'Matheus agradecendo' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#batepapo' --port=8551

# Rafaela se sincroniza, pois pararam de lhe enviar atualizações, e faz uma postagem pedindo desculpas por sua atitude
freechains --host=localhost:8553 peer localhost:8551 recv '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 recv '#batepapo' --port=8553
POST40=$(freechains chain "#batepapo" post inline 'Me desculpem pela forma como agi, eu queria parecer diferentona e legal... -Rafaela' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#batepapo' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#batepapo' --port=8553

# todos dão um último like de despedida
freechains chain "#batepapo" like $POST36 --sign=$PVTAtivo --port=8552
freechains chain "#batepapo" like $POST38 --sign=$PVTAtivo --port=8552
freechains chain "#batepapo" like $POST39 --sign=$PVTAtivo --port=8552

freechains chain "#batepapo" like $POST37 --sign=$PVTNoob --port=8552
freechains chain "#batepapo" like $POST38 --sign=$PVTNoob --port=8552
freechains chain "#batepapo" like $POST39 --sign=$PVTNoob --port=8552

freechains chain "#batepapo" like $POST36 --sign=$PVT1 --port=8552
freechains chain "#batepapo" like $POST37 --sign=$PVT1 --port=8552
freechains chain "#batepapo" like $POST39 --sign=$PVT1 --port=8552

freechains chain "#batepapo" like $POST36 --sign=$PVT2 --port=8552
freechains chain "#batepapo" like $POST37 --sign=$PVT2 --port=8552
freechains chain "#batepapo" like $POST38 --sign=$PVT2 --port=8552

# fim dos 3 meses (dias 92)
freechains-host now 8000200000 --port=8551
freechains-host now 8000200000 --port=8552
freechains-host now 8000200000 --port=8553

mostrar_reputacao "NO FIM DA SIMULAÇÃO"

