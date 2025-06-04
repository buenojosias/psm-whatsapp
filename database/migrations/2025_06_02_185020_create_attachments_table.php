<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained()->cascadeOnDelete(); // Referência à mensagem a que o anexo pertence
            $table->string('file_name'); // Nome do arquivo anexado
            $table->string('file_path'); // Caminho do arquivo no sistema de arquivos
            $table->string('file_type'); // Tipo MIME do arquivo, ex: 'image/jpeg', 'application/pdf', etc.
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attachments');
    }
};
