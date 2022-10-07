import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { StorageService } from 'src/app/services/storage.service';

@Component({
  selector: 'app-logout',
  templateUrl: './logout.component.html',
  styleUrls: ['./logout.component.scss']
})
export class LogoutComponent implements OnInit {

  constructor(private storageService: StorageService , private router : Router) { }
  logout(){
    this.storageService.clean();
    this.router.navigate(['']);
  }

  ngOnInit(): void {
  }

}
