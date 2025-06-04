<?php

namespace App\Enums;

enum ConversationStatusEnum: int
{
    case NOVA = 1; // Nova conversa, aguardando IA
    case ATENDIMENTO_IA = 2; // Conversa em atendimento pela IA
    case AGUARDANDO_HUMANO = 3; // Conversa transferida para um agente humano, aguardando resposta
    case ATENDIMENTO_HUMANO = 4; // Conversa em atendimento por um agente humano
    case PRE_FINALIZADA = 5; // IA definiu como resolvida, será finalizada dentro de algumas horas
    case FINALIZADA = 6; // Conversa finalizada após inatividade ou confirmação do contato, ou pelo agente humano
}
