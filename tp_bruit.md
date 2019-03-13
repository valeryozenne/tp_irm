---
title: "tp irm enseirb : bruit"
author: Aurélien Trottier, Valéry Ozenne
date: March 14, 2019
geometry: "left=4cm,right=4cm,top=2cm,bottom=2cm"
output: pdf_document
---




# Partie 1 : mesure de bruit avec un élément en réception

Charger le jeu de donnée `kspace_bruit.mat` situé dans le répertoire `data`. Vous disposez de données acquises sur un aimant Bruker 7T. L'acquisition a été réalisée sans échantillon afin d'évaluer et de quantifier le bruit présent lors d'une acquisition IRM.   

Les trois éléments (`image_combine`, `image_cplx`, `raw_data`) correspondent à l'image "sum of square", l'image complexe multicanaux, les données brutes en kspace.
Vous disposez maintenant d'une matrice complexe `image_cplx` de dimensions 128x128x1x1x4 voxels. Supprimer les dimensions 3 et 4 avec la sonction `squeeze`. La cinquième dimension est le nombre d'antennes. Extraire la partie réelle, imaginaire et la magnitude de l'antenne 1 et afficher le résultat.

Mesurer la déviation standard du bruit sur la partie réelle, imaginaire et la magnitude pour un canal et afficher l'histogramme du bruit.

Tracer un histogramme du bruit pour chaque reconstruction.

Nous allons maintenant chercher à "fitter" ces distribution, pour cela nous utiliserons la fonction `fitdist` avec une distribution gaussienne `normal`.

Pour rappel la formule de la distribution gaussienne est $f(x)=\frac{1}{\sigma\sqrt{2*\pi}}\exp{\Big(-\frac{1}{2}(\frac{x-\mu}{\sigma})\Big)}$

Superposer la fonction trouvée sur une fenêtre allant de $\mu-4*\sigma$ à $\mu+4*\sigma$

Quel est la relation entre la déviation standard de la magnitude $\sigma_{Ray}$ et la déviation standard de la partie imaginaire $\sigma_{g}$.

Appliquer la distribution de Rayleigh avec le $\sigma_{g}$ sur l'histogramme du bruit en magnitude.

Pour rappel la formule de la distribution Rayleigh est $f(x)=\frac{m}{\sigma_{g}}exp{\Big(\frac{-m^{2}} {2*\sigma^{2}_{g}}\Big)}H(m)$

Quelle est la relation enter la déviation standard de la magnitude et la distribution standard (fittée) de la partie imaginaire / réelle.

# Antennes en réseau phasé:

Une antenne de petit diamètre permet d’obtenir un meilleur un rapport signal / bruit en comparaison avec une antenne de grand diamètre. Cependant, sa couverture spatiale (la sensibilité volumique de l'antenne) est moins importante. En combinant plusieurs petites antennes (éléments d'antenne en réseau phasé) qui enregistrent de façon simultanée et indépendante le signal, on explore un volume plus grand. Grâce à la géométrie des antennes et à l’absence de corrélation du bruit enregistré par les différents éléments en réseau phasé le signal ainsi obtenu aura un meilleur rapport signal / bruit que celui délivré par une antenne unique de grandes dimensions. Employée de cette manière, l’acquisition avec une antenne constituée de plusieurs éléments en réseau phasé permet d’augmenter le rapport signal / bruit de l’image.

Chaque élément d’antenne a un volume de réception limité, avec des sensibilités variables en fonction de la distance par rapport à l’élément d’antenne. Le signal recueilli par chaque élément d’antenne comporte donc une information spatiale (position de l’antenne, volume de réception, sensibilité dans le volume) qui peut être utilisée pour reconstruire l’image, en complément du codage spatial induit par les gradients.

[adapté de IAMOS]

# Partie 2 : mesure de bruit avec plusieurs éléments en réception

L'objet de cette partie est de vérifier la validité des équations en présence de plusieurs éléments en réception.

Pour cela, nous allons effectuer les étapes suivantes en prenant le signal des 1, 2, 3 puis 4 éléments en réception. Pour chaque situation:

* calculer la "sum of square" du signal des antennes
* afficher l'histogramme
* connaissant la moyenne du signal du bruit et la déviation standard du bruit, tracer la distribution du signal théorique calculé à partir des deux formules suivantes (l'une étant la formulation théorique, l'autre l'approximation après développement de Taylor).

Pour rappel la formule de la déviation standard du bruit après développement de Taylor est la suivante:

\makebox[\linewidth]{$P_{m}(m_{L},\sigma_{G})=\frac{m^{2(L-1)}_{L}}{2^{L-1}\sigma^{2L}_{g}(L-1)!}exp{\Big(\frac{-m^{2}} {2*\sigma^{2}_{g}}\Big)}H(m)$}

Discuter de l'accord entre les données expérimentales et les données simulées en présence de 1, 2, 3,et 4 canaux. Que notez-vous?

# Partie 3 : mesure de covariance du bruit

Nous allons maintenant calculer la matrice de covariance du bruit. The noise covariance matrix describes the level and correlation of noise in the signals received in each element of the coil array. La matrice de covariance de bruit se calcule à partir d’acquisitions de bruit telles que celle utilisées ci dessus. Pour calculer $\Psi$, nous pouvons redimensionner nos données dans une matrice 2D [dimx*dimy, antennes] que l'on nommera M avec la fonction `reshape` et effectuer cette opération:

$\Psi=\frac{1}{dim_{x}dim_y} M*M'$

Quelle est la dimension de Psi ? Afficher Psi ? Quelle est la signification physique de $\Psi$?

La matrice de covariance comprend donc des termes qui traduisent les corrélations de bruit entre les éléments de réception (termes hors diagonale) ainsi que la variance du bruit capté par chaque récepteur (termes de la diagonale). L’on peut ainsi affirmer que les termes de la matrice de covariance de bruit montrent l’influence que les éléments de réception ont les uns par rapport aux autres [Anou SEWONU]. En pratique, cette matrice est rarement l'identité. Les algorithmes de reconstruction en IRM vont fournir un meilleur SNR si le bruit présent est blanc (le bruit est décorélé entre chaque antenne et la déviation standard est identique). Pour obtenir ceci , une étape est ajoutée avant la reconstruction qui consiste à créer un jeux de données d'antennes dits virtuelles comprenant un signal "pré blanchi or pre whitening" $s_{pw}$ tel qu'il existe une matrice L :

 \makebox[\linewidth]{$s_{pw}= L^{-1}s$}
  avec
\makebox[\linewidth]{$LL^{H}=\Psi$}


# Partie 4 : mesure de bruit avec plusieurs éléments en réception après "pre whitening"

Recommencer la partie 2 en prenant les données après "pre whitening" et comparer les résultats.
