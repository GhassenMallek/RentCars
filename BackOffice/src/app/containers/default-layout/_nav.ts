import { INavData } from '@coreui/angular';

export const navItems: INavData[] = [

  {
    name: 'Acceuil',
    url: '/acceuil',
    iconComponent: { name: 'cil-home' }

  },



  {
    name: 'Déconnecter',
    url: '/logout',
    iconComponent: { name: 'cil-account-logout' },

  },
  {
    name: 'Information genérals',
    title: true
  },


  {
    name: 'cars',
    url: '/charts',
    iconComponent: { name: 'cibPicartoTv' }
  },
  {
    name: 'users',
    iconComponent: { name: 'cilUser' },
    url: '/reclamation',

  },

];
