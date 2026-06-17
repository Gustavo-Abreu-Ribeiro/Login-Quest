function scr_load_day_tasks(_day) {
    ds_list_clear(global.task_list); // Limpa as tarefas do dia anterior
    
    switch(_day) {
        case 1:
            // Tarefa 1: Um e-mail muito óbvio (Phishing Nível 1)
            var _task1 = {
                type: "email",
                sender_name: "Premio Grátis",
                sender_email: "ganheja123@xyz.com",
                subject: "VOCÊ GANHOU UM IPHONE!",
                body: "Parabéns! Clique no link abaixo para resgatar seu prêmio agora mesmo.",
                is_threat: true,
                evidence_type: "sender", // O erro está no remetente
                explanation: "E-mails de prêmios com endereços genéricos são phishing."
            };
            ds_list_add(global.task_list, _task1);

            // Tarefa 2: Um e-mail real (Seguro)
            var _task2 = {
                type: "email",
                sender_name: "RH CyProtect",
                sender_email: "rh@cyprotect.com",
                subject: "Atualização de Benefícios",
                body: "Olá, a tabela de planos de saúde foi atualizada. Verifique no portal.",
                is_threat: false,
                evidence_type: "none",
                explanation: "E-mail interno legítimo vindo do domínio correto."
            };
            ds_list_add(global.task_list, _task2);
        break;
        
        case 2:
            // Aqui você adicionaria tarefas mais difíceis (Links falsos, etc)
        break;
    }
}