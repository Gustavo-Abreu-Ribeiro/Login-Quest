// Avança a página ao clicar
if (mouse_check_button_pressed(mb_left)) {
    pagina_atual++;
    
    // Se as páginas acabarem, o tutorial destrói-se e dá o "Play" no jogo
    if (pagina_atual >= array_length(paginas)) {
        obj_controller.hora_atual_minutos = 9 * 60;
        obj_controller.expediente_ativo = true;
        instance_destroy();
    }
}