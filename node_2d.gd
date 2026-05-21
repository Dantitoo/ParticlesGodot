extends Node2D

# --- REFERENCIAS DE ACCESO AL ÁRBOL DE NODOS ---
# Direccionamiento hacia las instancias de Sprite2D encapsuladas en la subescena 'Cauldron'
@onready var sprite_verde = $Cauldron/calderonVerde
@onready var sprite_rojo = $Cauldron/calderonRojo
@onready var sprite_azul = $Cauldron/calderonAzul

# Instancia del sistema de partículas por hardware subyacente
@onready var particles = $Cauldron/GPUParticles2D

# --- vectores de datos cromáticos (VALORES RGBA) ---
var color_rojo = Color("#ff4444")   # Atributo cromático para el estado ígneo
var color_azul = Color("#44aaff")   # Atributo cromático para el estado criogénico
var color_verde = Color("#44ff44")  # Atributo cromático para el estado ácido base

func _ready():
	# Enlace dinámico de señales (Observer Pattern) para eventos de interfaz de usuario
	$CanvasLayer/HBoxContainer/BtnRojo.pressed.connect(_on_btn_rojo_pressed)
	$CanvasLayer/HBoxContainer/BtnAzul.pressed.connect(_on_btn_azul_pressed)
	$CanvasLayer/HBoxContainer/BtnVerde.pressed.connect(_on_btn_verde_pressed)
	
	# Establecimiento del estado estacionario inicial del sistema
	actualizar_visibilidad_y_particulas(sprite_verde, color_verde)

# --- MÉTODOS DE CALLBACK (GESTIÓN DE EVENTOS DISCRETOS) ---

func _on_btn_rojo_pressed():
	print("¡Poción de fuego activada!")
	actualizar_visibilidad_y_particulas(sprite_rojo, color_rojo)

func _on_btn_azul_pressed():
	print("¡Poción de hielo activada!")
	actualizar_visibilidad_y_particulas(sprite_azul, color_azul)

func _on_btn_verde_pressed():
	print("¡Poción de ácido activada!")
	actualizar_visibilidad_y_particulas(sprite_verde, color_verde)

# --- MÉTODO PRINCIPAL DE CONTROL DE ESTADO Y FLUJO VISUAL ---

func actualizar_visibilidad_y_particulas(sprite_activo: Sprite2D, nuevo_color: Color):
	# 1. GESTIÓN DE VISIBILIDAD DE LOS RECURSOS DE TEXTURA
	# Conmutación masiva a estado no visible para evitar sobreposición en el búfer de renderizado
	sprite_verde.visible = false
	sprite_rojo.visible = false
	sprite_azul.visible = false
	
	# Asignación de visibilidad exclusiva al nodo indexado por el evento
	if sprite_activo:
		sprite_activo.visible = true

	# 2. MODIFICACIÓN DINÁMICA DEL RECURSO DE PROCESAMIENTO GRÁFICO
	# Conversión explícita de tipo hacia ParticleProcessMaterial para acceder a las propiedades de cómputo
	var material_particulas = particles.process_material as ParticleProcessMaterial
	
	if material_particulas and material_particulas.color_ramp:
		var textura_gradiente = material_particulas.color_ramp as GradientTexture1D
		var gradiente = textura_gradiente.gradient
		
		if gradiente:
			# Modificación del índice cromático 0 (punto de origen/instanciación)
			gradiente.set_color(0, nuevo_color)
			# Modificación del índice cromático 1 con canal Alfa nulo (interpolación hacia la transparencia)
			gradiente.set_color(1, Color(nuevo_color.r, nuevo_color.g, nuevo_color.b, 0))
			
			# Notificación forzada al pipeline de gráficos para mitigar problemas de latencia en la mutación del búfer
			textura_gradiente.emit_changed()
			particles.emit_changed()
	else:
		# Bloque de contingencia: Asignación directa de color plano si el recurso de gradiente no está alocado
		material_particulas.color = nuevo_color
