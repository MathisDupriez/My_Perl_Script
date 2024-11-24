#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use LWP::UserAgent;

# Configuration
my $github_api_url = "https://api.github.com";
my $personal_access_token = $ENV{GITHUB_TOKEN} or die "Erreur : La variable d'environnement GITHUB_TOKEN est requise.\n";

sub run_command {
    my ($command) = @_;
    print "Exécution : $command\n";
    my $output = `$command 2>&1`;
    my $status = $? >> 8;
    die "Erreur lors de la commande : $output\n" if $status != 0;
    return $output;
}

sub create_github_repo {
    print "Nom du dépôt GitHub : ";
    chomp(my $repo_name = <STDIN>);
    die "Erreur : Nom du dépôt non valide.\n" unless $repo_name =~ /^[a-zA-Z0-9_.-]+$/;

    print "Description du dépôt (optionnel) : ";
    chomp(my $description = <STDIN>);
    print "Voulez-vous que le dépôt soit privé ? (oui/non) : ";
    chomp(my $is_private = <STDIN>);
    $is_private = lc($is_private) eq "oui" ? JSON::true : JSON::false;

    my $ua = LWP::UserAgent->new;
    $ua->default_header(
        "Authorization" => "token $personal_access_token",
        "Content-Type"  => "application/json"
    );

    my $payload = {
        "name"        => $repo_name,
        "description" => $description,
        "private"     => $is_private,
    };
    my $response = $ua->post("$github_api_url/user/repos", Content => encode_json($payload));

    unless ($response->is_success) {
        my $error_message = eval { decode_json($response->decoded_content)->{message} } || $response->decoded_content;
        die "Erreur lors de la création du dépôt GitHub : $error_message\n";
    }

    my $repo_data = decode_json($response->decoded_content);
    print "Dépôt GitHub créé avec succès : $repo_data->{clone_url}\n";
    return $repo_data->{clone_url}; # Utilise l'URL HTTPS
}

sub initialize_local_repo {
    my ($repo_url) = @_;
    print "Chemin du dossier local pour le dépôt : ";
    chomp(my $local_path = <STDIN>);

    if (-d $local_path) {
        print "Le dossier existe déjà. Continuer ? (oui/non) : ";
        chomp(my $continue = <STDIN>);
        die "Abandon de l'opération.\n" if lc($continue) ne "oui";
    } else {
        mkdir $local_path or die "Impossible de créer le dossier $local_path : $!\n";
    }

    chdir $local_path or die "Impossible d'accéder au dossier $local_path : $!\n";
    run_command("git init");
    run_command("git remote add origin $repo_url");
    run_command("git config --local credential.helper 'store'");
}

sub push_to_github {
    run_command("git add .");
    run_command("git commit -m 'Initial commit'");
    run_command("git branch -M main");
    run_command("git push -u origin main");
    print "Dépôt local initialisé et contenu poussé.\n";
}

# Exécution
my $repo_url = create_github_repo();
initialize_local_repo($repo_url);
push_to_github();
