class_name Player # Define o nome da classe para ser usada em outros scripts
extends CharacterBody2D # Indica que este script herda de CharacterBody2D (personagem com física 2D)

@onready var animation: AnimationPlayer = $body/animation # Referência ao nó AnimationPlayer dentro do corpo
@onready var invincible_timer := $invincible_timer # Referência ao timer que controla o tempo de invencibilidade
@onready var blink_timer := $blink_timer # Referência ao timer que controla o piscar do sprite
@onready var dash_cooldown: Timer = $dash_cooldown # Referência ao timer que controla o tempo de recarga do dash
@onready var audio = $audio as AudioStreamPlayer # Referência ao áudio de pulo
@onready var morte = $morte as AudioStreamPlayer # Referência ao áudio de morte
@onready var poder = $poder as AudioStreamPlayer # Referência ao som do poder (tiro)

const BULLET := preload("res://atores/player/projectiles/bullet.tscn") # Carrega a cena do projétil do jogador
const SPEED := 150 # Velocidade de movimentação horizontal
const DEATH_HEIGHT := 500 # Altura limite: se cair abaixo disso, o jogador morre
const DASH_SPEED := 500 # Velocidade durante o dash
const DASH_DURATION := 0.15 # Duração do dash em segundos

var life := 3 # Vida inicial do jogador
var is_dead := false # Define se o jogador está morto
var dash_timer := 0.0 # Temporizador para controlar a duração do dash
var jump_height := 90 # Altura do pulo
var time_to_top_height := 0.5 # Tempo para atingir a altura máxima do pulo
var jump_velocity # Velocidade do pulo (calculada em _ready)
var gravity # Gravidade na subida
var fall_gravity # Gravidade na queda (dobrada)

var direction = 0.0 # Direção do movimento: -1 esquerda, 1 direita, 0 parado

var can_dash := true # Define se o jogador pode usar dash
var is_dashing := false # Define se o jogador está dashing
var is_invincible := false # Define se o jogador está invencível
var is_damaged := false # Define se o jogador tomou dano
var is_shooting := false # Define se o jogador está atirando
var current_state := "idle" # Estado atual de animação

func _ready():
	jump_velocity = (jump_height * 2) / time_to_top_height # Fórmula para calcular a velocidade do pulo
	gravity = (jump_height * 2) / pow(time_to_top_height, 2) # Fórmula para calcular a gravidade de subida
	fall_gravity = gravity * 2 # Gravidade da queda é o dobro da subida

func _physics_process(delta):
	var dash_active := UpgradeManager.dash_upgrated # Verifica se o dash está desbloqueado
	var shoot_active := UpgradeManager.shoot_upgrated # Verifica se o tiro está desbloqueado

	if global_position.y > DEATH_HEIGHT: # Se cair abaixo do limite de altura
		die() # Executa a função de morte

	if is_dead: # Se estiver morto
		velocity.x = 0 # Para o movimento horizontal
		velocity.y += fall_gravity * delta # Continua caindo com gravidade
		move_and_slide() # Aplica o movimento
		set_state() # Atualiza a animação
		return

	direction = Input.get_axis("move_left", "move_right") # Recebe input de movimento horizontal (esquerda ou direita)

	if !is_damaged: # Se não estiver tomando dano
		velocity.x = direction * SPEED # Aplica velocidade horizontal

	if direction != 0 and !is_shooting: # Se estiver andando e não atirando
		flip_sprite(direction) # Vira o sprite na direção do movimento

	if Input.is_action_just_pressed("jump") and is_on_floor(): # Se pressionou o pulo e está no chão
		velocity.y = -jump_velocity # Aplica velocidade de pulo
		audio.play() # Toca o som de pulo

	if !is_on_floor(): # Se estiver no ar
		if Input.is_action_pressed("jump") and velocity.y < 0: # Se ainda está subindo e segurando o botão
			velocity.y += gravity * delta # Aplica gravidade de subida
		else:
			velocity.y += fall_gravity * delta # Aplica gravidade de queda

	if Input.is_action_just_pressed("right_click") and !is_shooting and shoot_active: # Se clicou botão de tiro e não está atirando
		is_shooting = true # Marca como atirando
		shoot() # Executa o tiro (inclui criação da bala e som)

	if Input.is_action_just_pressed("dash") and direction != 0 and can_dash and dash_active: # Se pressionou dash
		is_dashing = true # Ativa dash
		dash_timer = DASH_DURATION # Define a duração do dash

	if is_dashing: # Se estiver dashing
		dash() # Executa movimento de dash
		dash_timer -= delta # Diminui o tempo restante
		if dash_timer <= 0: # Se o tempo acabou
			is_dashing = false # Finaliza o dash
			is_invincible = false # Fica vulnerável novamente

	if is_shooting and !animation.is_playing(): # Se terminou a animação de tiro
		is_shooting = false

	if is_damaged and !animation.is_playing(): # Se terminou a animação de dano
		is_damaged = false

	set_state() # Atualiza a animação de acordo com o estado atual
	move_and_slide() # Aplica movimento

func dash():
	velocity.x = direction * DASH_SPEED # Aplica velocidade rápida na direção do movimento
	can_dash = false # Desativa o dash temporariamente
	is_invincible = true # Fica invencível durante o dash
	dash_cooldown.start() # Inicia o tempo de recarga do dash

func set_state():
	var new_state = "idle" # Estado padrão

	if is_dead:
		new_state = "die" # Se estiver morto
	elif is_shooting:
		new_state = "shoot" # Se estiver atirando
	elif is_damaged:
		new_state = "hurt" # Se estiver tomando dano

	if current_state != new_state: # Se o estado mudou
		animation.play(new_state) # Toca nova animação
		current_state = new_state # Atualiza o estado atual

func die():
	if is_dead:
		return # Evita múltiplas execuções

	is_dead = true # Marca como morto
	velocity = Vector2.ZERO # Para o movimento

	if not morte.playing:
		morte.play() # Toca som de morte

	await morte.finished # Espera o som terminar
	fall_off_screen() # Reinicia a cena atual

func take_damage(damage: int, enemie_position := Vector2.ZERO):
	if is_invincible or is_dead:
		return # Se invencível ou morto, ignora

	is_damaged = true # Marca como danificado
	knockback(enemie_position) # Aplica empurrão
	enable_invincibility() # Ativa invencibilidade temporária
	life -= damage # Reduz vida

	if life <= 0:
		die() # Morre se a vida acabar

func shoot():
	var bullet = BULLET.instantiate() # Cria uma instância do projétil
	add_sibling(bullet, true) # Adiciona o projétil como irmão na árvore de nós
	var direct = sign($body.scale.x) # Define direção com base na escala do sprite (esquerda ou direita)
	bullet.set_direction(direct) # Define direção do projétil
	bullet.position = $body/bullet_point.global_position # Posiciona a bala na ponta do canhão (bullet_point)
	poder.play() # Toca o som do poder (tiro)

func flip_sprite(dir):
	$body.scale.x = sign(dir) # Inverte o sprite horizontalmente com base na direção

func knockback(dir):
	var knock_direction = sign(global_position.x - dir.x) # Define a direção oposta ao dano
	velocity.x = knock_direction * 100 # Aplica um empurrão na direção oposta

func enable_invincibility():
	is_invincible = true # Ativa invencibilidade
	set_collision_mask_value(3, false) # Desativa colisão com camada 3 (inimigos)
	blink_timer.start() # Começa a piscar
	invincible_timer.start() # Inicia o tempo de invencibilidade

func _on_invincible_timer_timeout() -> void:
	is_invincible = false # Fim da invencibilidade
	set_collision_mask_value(3, true) # Reativa colisão com inimigos
	blink_timer.stop() # Para o piscar
	$body/sprite.visible = true # Garante que o sprite fique visível

func _on_blink_timer_timeout() -> void:
	$body/sprite.visible = !$body/sprite.visible # Alterna visibilidade para piscar

func _on_dash_cooldown_timeout() -> void:
	can_dash = true # Permite o uso do dash novamente

func fall_off_screen():
	get_tree().reload_current_scene() # Reinicia a cena atual
