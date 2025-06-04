<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('contacts', function (Blueprint $table) {
            $table->id();
            $table->string('phone', 20)->unique()->index(); // O número do WhatsApp para buscar o contato
            $table->string('name', 100)->nullable(); // Nome do contato, nullable porque pode não ser informado pela API
            $table->string('photo_url')->nullable(); // URL da foto do contato, nullable porque pode não ser informado pela API
            $table->date('birth_date')->nullable(); // Data de nascimento do contato, será preenchida quando o usuário informar
            $table->boolean('is_parishioner')->nullable();
            $table->integer('tithe_number')->nullable(); // Número do dizimista, para quando enviar comprovante de dízimo
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('contacts');
    }
};
