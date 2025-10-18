# Skeleton for running a macro-level PNR flow based on my RTL2GDS YouTube Series

This repo contains the skeleton scripts for running a full RTL2GDS flow using Cadence tools, as demonstrated in the Full RTL2GDS Demo prepared and delivered by Prof. Adam (Adi) Teman of the EnICS Labs Institute at Bar-Ilan University. 

## Tutorial Videos and Slides
The videos and slides for the demo can be found at https://enicslabs.com/academic-courses/rtl2gds-demo/ or on the YouTube playlist at https://youtube.com/playlist?list=PLZU5hLL_713zf_i38C7uLu5pUz5wTjKul&si=L5WXarCnpWddJSTT

## Directory Structure

The directory structure is explained in the video at https://youtu.be/GsjvA9CX33Q

All of your tools should be run from the *workspace/* directory (or any other directory you create at the same path level - there's nothing special about the *workspace/* directory, such that when you want a clean run, you can just delete it and start over).

The rest of the directories include:
- *inputs/* - A directory that has all the input files for your design, such as Defines, SDC, MMMC, etc.
- *libraries/* - A directory that has all the definitions for the Process-specific IP you will be using, such as PDK, standard cells, SRAMs, IOs.
- *scripts/* - The directory that has all of the skeleton template scripts that are used in the tutorial.
- *sourcecode/* - A directory for organizing your RTL. 
- *reports/* - The output directory, where all generated reports will be written to.
- *export/* - The output directory, where all products of the flow will be written to (except for restore point dbs).
- *dbs/* - The output directory, where all restore point databases will be stored.
- *mem_gen/* - An example directory where compiled SRAM cuts could be generated and stored in (optional).
- *apps/* - A directory for putting C-code that can run on the PULP toolchain that is provided in the example
- *docs/* - A set of supporting documents (user manuals), written by Prof. Teman and provided to you for a deeper dive into the material.

## Acknowledgement

I would like to first and foremost thank Bar-Ilan University and the Alexander Kofkin Faculty of Engineering, where I spend the majority of my time as a Professor of Electrical Engineering. Of course, this focuses on the entire staff, teams, students and alumni of the Emerging Nanoscaled Integrated Circuits and Systems (EnICS) Labs Institute, of which I am a co-director. Specifically, I would like to point out our amazing faculty members, Prof. Alex Fish, Prof. Yossie Shor, Prof. Itamar Levi, Dr. Leonid Yavits and Prof. Osnat Keren, as well as our senior staff members, Dr. Yoav Weitzman, Dr. Udi Kra, Yonatan Shoshan, Slava Yuzhaninov, Yehuda Rudin, Noa Edri, and a whole bunch of others - past and present.

Special thanks to Shawn Ruby and RubyEDA for providing me with the environment and support for creating this tutorial and teaching me a lot, since I started working with Shawn in 2015.

Another shout out to the Cadence Academic Network that provides me with the EDA tools that are used in this tutorial, but I will also note the other EDA providers and vendors of IP and process technologies, with whom I also work a lot and get a lot of stuff from them.

Special acknowledgement to Prof. Andreas Burg and the Telecommunications Circuits Lab at EPFL and all of my colleagues there. I did my post-doc at EPFL and learned a lot of this stuff from the amazing staff and students there. In addition, I would like to thank and acknowledge Prof. Luca Benini of ETH-Zurich and his amazing PULP project and team, who I have had the fortune to work with and get to know, including Prof. Davide Rossi, Dr. Frank Gurkaynak, Dr. Davide Schiavionne, Dr. Florian Zaruba and many others who I have learned a ton from along the way and also provided the majority of the RTL in this demo. 

## Disclaimer

A final disclaimer is that I have done my best and utmost to remove all and any proprietary information or IP from this repository and from the publicly available videos. If, by chance, you notice that I missed something, please inform me at adam.teman@biu.ac.il and I will try to fix it as soon as I possibly can.

