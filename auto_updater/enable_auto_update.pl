#!/usr/bin/perl
use strict;
use warnings;

my $script_path = "/opt/script/auto_updater/auto_update.pl";

# Vérifie si le script de logique existe
unless (-f $script_path) {
    die "Erreur : Le script de logique $script_path n'existe pas.\n";
}

# Ajouter une tâche cron pour exécuter le script toutes les heures
my $cron_hourly = "0 * * * * perl $script_path";
add_cron_job($cron_hourly, "Exécution horaire");

# Ajouter une tâche cron pour exécuter le script au démarrage
my $cron_startup = "\@reboot perl $script_path";  # Notez l'échappement de '@'
add_cron_job($cron_startup, "Exécution au démarrage");

print "Les tâches cron ont été configurées avec succès.\n";

# Fonction pour ajouter une tâche cron
sub add_cron_job {
    my ($job, $description) = @_;

    # Lire les tâches cron existantes
    my @cron_jobs = `crontab -l 2>/dev/null`;

    # Vérifie si la tâche est déjà présente
    unless (grep { /^\Q$job\E$/ } @cron_jobs) {  # Vérifie l'existence exacte
        open(my $crontab_fh, '|-', 'crontab -') or die "Impossible d'ouvrir crontab : $!\n";
        print $crontab_fh @cron_jobs;   # Ajouter les tâches existantes
        print $crontab_fh "$job\n";     # Ajouter la nouvelle tâche
        close($crontab_fh);
        print "$description ajouté aux tâches cron.\n";
    } else {
        print "$description est déjà présent dans les tâches cron.\n";
    }
}
