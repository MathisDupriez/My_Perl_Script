#!/usr/bin/perl
use strict;
use warnings;

# Mettre à jour le système
print "Mise à jour du système en cours...\n";
my $status = system("sudo dnf -y update");

# Vérifier le statut de la mise à jour
if ($status == 0) {
    # Notification de succès
    system("notify-send 'Mise à jour du système' 'La mise à jour est terminée avec succès.'");
    print "Mise à jour terminée avec succès.\n";
} else {
    # Notification d'erreur
    system("notify-send 'Mise à jour du système' 'Une erreur est survenue pendant la mise à jour.'");
    print "Une erreur est survenue pendant la mise à jour. Code de sortie : $status\n";
}
