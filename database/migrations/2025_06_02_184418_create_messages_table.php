<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained()->cascadeOnDelete();
            $table->enum('sent_by', ['contact', 'human', 'ai']);
            $table->text('content')->nullable(); // Mensagem de texto
            $table->string('audio_path')->nullable(); // Caminho do áudio, se for uma mensagem de áudio
            $table->integer('tokens')->nullable(); // Número de tokens consumidos pela IA para gerar a resposta para análise consumo
            $table->timestamps(); // Ver se é possível manter apenas created_at ou sent_at
            $table->dateTime('read_at')->nullable(); // Data e hora em que a mensagem foi lida, pode ser nulo se não foi lida
            $table->softDeletes(); // Para manter histórico de mensagens excluídas
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
