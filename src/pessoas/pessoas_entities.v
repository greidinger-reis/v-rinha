module pessoas

import json
import time

[table: 'pessoas']
pub struct Pessoa {
pub:
	id         string [primary; sql_type: 'uuid']
	nome       string [nonnull; required; sql_type: 'varchar(100)']
	apelido    string [nonnull; required; sql_type: 'varchar(32)'; unique]
	nascimento string [nonnull; required; sql_type: 'char(10)']
	stack      string
	search     string [nonnull]
}

pub fn pessoa_from_json(json_str string) !&Pessoa {
	return pessoadto_from_json(json_str)!.to_pessoa()
}

pub fn (p &Pessoa) to_dto() &PessoaDto {
	return &PessoaDto{
		id: p.id
		nome: p.nome
		apelido: p.apelido
		nascimento: p.nascimento
		stack: p.stack.split(',')
	}
}

pub fn (p &Pessoa) to_json() string {
	return p.to_dto().to_json()
}

pub fn (p []Pessoa) to_json() string {
	dto_list := p.map(*it.to_dto())
	return json.encode(dto_list)
}

pub struct PessoaDto {
	nome       string   [required]
	apelido    string   [required]
	nascimento string   [required]
	stack      []string
mut:
	id string
}

pub fn pessoadto_from_json(data string) !&PessoaDto {
	mut dto := json.decode(PessoaDto, data)!
	time.parse_format(dto.nascimento, 'YYYY-MM-DD') or {
		return error('invalid date ${dto.nascimento}')
	}

	if dto.apelido.len > 32 {
		return error('invalid apelido length. max: 32')
	}
	if dto.nome.len > 100 {
		return error('invalid nome length. max: 100')
	}

	return &dto
}

pub fn (dto &PessoaDto) to_json() string {
	return json.encode(dto)
}

pub fn (dto &PessoaDto) to_pessoa() &Pessoa {
	stack := dto.stack.join(',')

	return &Pessoa{
		id: dto.id
		nome: dto.nome
		apelido: dto.apelido
		nascimento: dto.nascimento
		stack: stack
	}
}
