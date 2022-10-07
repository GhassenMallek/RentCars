import { Component } from '@angular/core';
import { StorageService } from 'src/app/services/storage.service';

import { navItems } from './_nav';

@Component({
  selector: 'app-dashboard',
  templateUrl: './default-layout.component.html',
})
export class DefaultLayoutComponent {

  public navItems = navItems;
  email: string;

  public perfectScrollbarConfig = {
    suppressScrollX: true,
  };

  constructor( private storageService: StorageService) {
  this.email = this.storageService.getUser().user.email;
  console.log(this.email);


  }
}
