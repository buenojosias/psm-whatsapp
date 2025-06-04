<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('contact_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete(); // Agente humano que está atendendo a conversa, pode ser nulo se agente for IA
            $table->string('subject', 30)->nullable(); // Assunto da conversa, só será definida após a IA ou um agente humano definir. Ex: "Dízimo", "Batismo", "Casamento", etc.
            $table->text('summary')->nullable(); // Resumo da conversa, enviar a cada requisição para a IA e o agente humano saber do que se trata
            $table->enum('agent_type', ['human', 'ai'])->default('ai');
            $table->enum('started_by', ['contact', 'human', 'ai'])->default('contact'); // Quem iniciou a conversa
            $table->smallInteger('status')->default(1)->index(); // Status da conversa. Opções na class ConversationStatusEnum
            $table->timestamps();
            $table->datetime('last_message_at')->nullable(); // Decidir se será mesmo necessário
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};
