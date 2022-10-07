import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent implements OnInit {

  form: any = {
    fullname: '',
    email: '',
    password: '',
    phoneMonile:null,
    phoneFixe: null,
    address:'',
    website:'',
    role:'',


  };
  isSuccessful = false;
  isSignUpFailed = false;
  errorMessage = '';
  constructor(private authService: AuthService, private router: Router) { }

  onSubmit(): void {
    const { fullname, email, password, phoneMobile, phoneFixe, address,webSite,role } = this.form;

    this.authService.register(fullname, email, password, phoneMobile, phoneFixe, address,webSite,role).subscribe({
      next: data => {
        console.log(data);
        this.isSuccessful = true;
        this.isSignUpFailed = false;
        if (this.isSuccessful)
        {
          this.router.navigate(['/']);
        }
      },
      error: err => {
        this.errorMessage = err.error.message;
        this.isSignUpFailed = true;
      }
    });
  }

  ngOnInit(): void {
  }

}
